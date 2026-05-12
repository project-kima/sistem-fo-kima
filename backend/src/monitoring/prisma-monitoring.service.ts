import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
  ContractStatus,
  CoreAllocationType,
  CustomerStatus,
  InvoiceStatus,
  MonitoringAlert,
  MonitoringBillingRow,
  RouteFlowStatus,
} from '../shared/types/domain.types';

const toIsoDate = (value: Date | null | undefined): string | null =>
  value ? value.toISOString().slice(0, 10) : null;

const parseDate = (value: string): Date => new Date(`${value}T00:00:00.000Z`);

const addDays = (value: string, days: number): string => {
  const next = parseDate(value);
  next.setUTCDate(next.getUTCDate() + days);
  return next.toISOString().slice(0, 10);
};

const monthLabel = [
  '',
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

@Injectable()
export class PrismaMonitoringService {
  constructor(private readonly prisma: PrismaService) {}

  isEnabled(): boolean {
    return (
      this.prisma.isEnabled() && process.env.MONITORING_SOURCE === 'prisma'
    );
  }

  async getBilling(query: { year?: string; isp?: string; status?: string }) {
    const year = this.parseYear(query.year);
    const status = this.parseInvoiceStatus(query.status);
    const rows = await this.getMonitoringBillingRows(year, {
      isp: query.isp,
      status,
    });
    const summary = this.buildSummary(rows);

    return {
      year,
      appliedFilters: {
        isp: query.isp ?? null,
        status: status ?? null,
      },
      summary,
      rows,
    };
  }

  async getAlerts(query: { year?: string }) {
    const year = this.parseYear(query.year);

    return {
      year,
      alerts: await this.getMonitoringAlerts(year),
    };
  }

  async getInsights(query: { year?: string }) {
    const year = this.parseYear(query.year);
    return this.getMonitoringInsights(year);
  }

  private async getMonitoringBillingRows(
    year: number,
    filters?: {
      isp?: string;
      status?: InvoiceStatus;
    },
  ): Promise<MonitoringBillingRow[]> {
    const today = new Date().toISOString().slice(0, 10);
    const currentMonth = new Date(today).getUTCMonth() + 1;
    const currentYear = new Date(today).getUTCFullYear();

    const customers = await this.prisma.customer.findMany({
      where: { status: CustomerStatus.Aktif },
      orderBy: { name: 'asc' },
      include: {
        ispMemberships: {
          include: { isp: true },
        },
        contracts: {
          orderBy: { id: 'desc' },
          include: {
            versions: {
              orderBy: { versionNumber: 'desc' },
            },
          },
        },
        invoices: {
          where: {
            periodYear: year,
            scheduleStatus: 'active',
          },
          orderBy: [{ periodMonth: 'asc' }, { id: 'asc' }],
        },
        routeVersions: {
          orderBy: { versionNumber: 'desc' },
          take: 1,
        },
      },
    });

    const rows = customers.map((customer) => {
      const customerIsps = [...(customer.ispMemberships ?? [])]
        .map((membership) => membership.isp)
        .sort((left, right) => left.name.localeCompare(right.name));

      const primaryIsp = customerIsps[0];
      const primaryIspName = primaryIsp?.name ?? customer.ispName ?? '-';
      const ispContractStart = primaryIsp?.contractStartDate
        ? primaryIsp.contractStartDate.toISOString().slice(0, 10)
        : null;

      const contract = [...(customer.contracts ?? [])].sort(
        (left, right) => right.id - left.id,
      )[0];
      const latestVersion = [...(contract?.versions ?? [])].sort(
        (left, right) => right.versionNumber - left.versionNumber,
      )[0];

      // Find current month invoice, or fallback to the most recent one issued
      let currentMonthInvoice = customer.invoices.find(
        (inv) =>
          inv.periodYear === currentYear &&
          inv.periodMonth === currentMonth &&
          inv.scheduleStatus === 'active',
      );

      if (!currentMonthInvoice) {
        currentMonthInvoice = [...customer.invoices]
          .filter((inv) => inv.scheduleStatus === 'active')
          .sort((a, b) => {
            if (a.periodYear !== b.periodYear)
              return b.periodYear - a.periodYear;
            return b.periodMonth - a.periodMonth;
          })[0];
      }

      const months = Array.from({ length: 12 }, (_, monthIndex) => {
        const month = monthIndex + 1;
        const invoice = customer.invoices.find(
          (item) =>
            item.periodYear === year &&
            item.periodMonth === month &&
            item.scheduleStatus === 'active',
        );

        return invoice
          ? (invoice.status as InvoiceStatus)
          : InvoiceStatus.BelumDitagih;
      });

      return {
        customerId: customer.id,
        customerCode: customer.customerCode,
        ispName: primaryIspName,
        ispNames: customerIsps.map((isp) => isp.name),
        ispContractStart,
        customerName: customer.name,
        customerStatus: customer.status as CustomerStatus,
        contractNumber: contract?.contractNumber ?? null,
        currentInvoiceNumber: currentMonthInvoice?.invoiceNumber ?? null,
        routeStatus:
          (customer.routeVersions[0]?.flowStatus as RouteFlowStatus) ?? null,
        activationFeeAmount: Number(customer.activationFeeAmount ?? 0),
        activationFeePaidAt: customer.activationFeePaidAt
          ? customer.activationFeePaidAt.toISOString()
          : null,
        contractStart:
          toIsoDate(latestVersion?.startDate) ?? toIsoDate(contract?.startDate),
        contractEnd:
          toIsoDate(latestVersion?.endDate) ?? toIsoDate(contract?.endDate),
        coreType:
          (latestVersion?.coreType as CoreAllocationType | undefined) ??
          (contract?.coreType as CoreAllocationType | undefined) ??
          null,
        coreTotal: latestVersion?.coreTotal ?? contract?.coreTotal ?? null,
        sharingRatio:
          latestVersion?.sharedCoreRatio ?? contract?.sharingRatio ?? null,
        monthlyAmount: Number(latestVersion?.monthlyAmount ?? 0),
        yearlyAmount: Number(latestVersion?.yearlyAmount ?? 0),
        notes: customer.notes ?? null,
        contractRemarks: latestVersion?.remarks ?? null,
        months,
      } satisfies MonitoringBillingRow;
    });

    return rows.filter((row) => {
      const normalizedIspFilter = filters?.isp?.trim().toLowerCase();
      const ispMatch = normalizedIspFilter
        ? [row.ispName, ...(row.ispNames ?? [])]
            .join(' ')
            .toLowerCase()
            .includes(normalizedIspFilter)
        : true;
      const statusMatch = filters?.status
        ? row.months.includes(filters.status)
        : true;
      return ispMatch && statusMatch;
    });
  }

  private async getMonitoringInsights(year: number) {
    const invoices = await this.prisma.invoice.findMany({
      where: {
        periodYear: year,
        scheduleStatus: 'active',
      },
      select: {
        periodMonth: true,
        amount: true,
        status: true,
      },
    });

    const contractVersions = await this.prisma.contractVersion.findMany({
      where: {
        bakDocumentId: { not: null },
        contract: {
          status: { not: ContractStatus.Terminated },
        },
      },
      include: {
        contract: {
          select: { status: true },
        },
      },
    });

    const months = Array.from({ length: 12 }, (_, index) => {
      const month = index + 1;
      const monthInvoices = invoices.filter(
        (invoice) => invoice.periodMonth === month,
      );

      const revenueProjected = monthInvoices.reduce(
        (sum, invoice) => sum + Number(invoice.amount ?? 0),
        0,
      );
      const revenuePaid = monthInvoices
        .filter((invoice) => invoice.status === 'lunas')
        .reduce((sum, invoice) => sum + Number(invoice.amount ?? 0), 0);

      const monthStart = new Date(Date.UTC(year, month - 1, 1));
      const monthEnd = new Date(Date.UTC(year, month, 0));

      const activeRentals = contractVersions.filter((version) => {
        const versionStart = version.startDate;
        const versionEnd = version.endDate;

        return (
          versionStart.getTime() <= monthEnd.getTime() &&
          versionEnd.getTime() >= monthStart.getTime()
        );
      }).length;

      return {
        month,
        revenuePaid,
        revenueProjected,
        activeRentals,
      };
    });

    const revenuePaid = months.reduce((sum, item) => sum + item.revenuePaid, 0);
    const revenueProjected = months.reduce(
      (sum, item) => sum + item.revenueProjected,
      0,
    );
    const estimatedProfit = Math.round(revenuePaid * 0.28);
    const averageActiveRentals = Math.round(
      months.reduce((sum, item) => sum + item.activeRentals, 0) / months.length,
    );

    return {
      year,
      months,
      totals: {
        revenuePaid,
        revenueProjected,
        estimatedProfit,
        averageActiveRentals,
      },
    };
  }

  private async getMonitoringAlerts(year: number): Promise<MonitoringAlert[]> {
    const today = new Date().toISOString().slice(0, 10);
    const currentMonth = parseDate(today).getUTCMonth() + 1;
    const currentYear = parseDate(today).getUTCFullYear();

    const customers = await this.prisma.customer.findMany({
      where: { status: CustomerStatus.Aktif },
      orderBy: { name: 'asc' },
      include: {
        contracts: {
          orderBy: { id: 'desc' },
          include: {
            versions: {
              orderBy: { versionNumber: 'desc' },
            },
          },
        },
        invoices: {
          where: {
            scheduleStatus: 'active',
          },
          orderBy: [{ periodYear: 'desc' }, { periodMonth: 'desc' }],
        },
        documents: {
          select: {
            jenisDokumen: true,
          },
        },
      },
    });

    const alerts: MonitoringAlert[] = [];

    customers.forEach((customer) => {
      const contracts = [...(customer.contracts ?? [])].sort(
        (left, right) => right.id - left.id,
      );
      const primaryContract = contracts[0] ?? null;
      const contractVersions = [...(primaryContract?.versions ?? [])].sort(
        (left, right) => right.versionNumber - left.versionNumber,
      );
      const activeVersion = this.findActiveContractVersion(
        contractVersions.map((version) => ({
          id: version.id,
          startDate: toIsoDate(version.startDate)!,
          endDate: toIsoDate(version.endDate)!,
          bakDocumentId: version.bakDocumentId,
        })),
        (primaryContract?.status as ContractStatus | null) ?? null,
        today,
      );

      if (!activeVersion) {
        alerts.push({
          customerId: customer.id,
          customerName: customer.name,
          code: 'missing_contract',
          severity: 'high',
          message: 'Tenant belum memiliki kontrak aktif yang tervalidasi BAK.',
        });
      }

      const currentInvoices = customer.invoices.filter(
        (invoice) => invoice.scheduleStatus === 'active',
      );

      const hasCurrentMonthInvoice = currentInvoices.some(
        (invoice) =>
          invoice.periodYear === currentYear &&
          invoice.periodMonth === currentMonth &&
          Boolean(invoice.invoiceFileUrl),
      );

      if (!hasCurrentMonthInvoice && year === currentYear) {
        alerts.push({
          customerId: customer.id,
          customerName: customer.name,
          code: 'missing_invoice_current_month',
          severity: 'medium',
          message: `Invoice bulan ${monthLabel[currentMonth]} belum tersedia untuk tenant ini.`,
        });
      }

      const priorityAlerts = this.buildPriorityAlerts(
        customer.id,
        customer.name,
        currentInvoices.map((invoice) => ({
          status: invoice.status as InvoiceStatus,
          dueDate: toIsoDate(invoice.dueDate),
          invoiceFileUrl: invoice.invoiceFileUrl,
          paymentProofFileUrl: invoice.paymentProofFileUrl,
          amount: Number(invoice.amount ?? 0),
        })),
        activeVersion,
        today,
      );
      alerts.push(...priorityAlerts);

      const latestVersion = contractVersions[0] ?? null;
      if (latestVersion && latestVersion.bakDocumentId === null) {
        alerts.push({
          customerId: customer.id,
          customerName: customer.name,
          code: 'bak_missing',
          severity: 'high',
          message: `Versi kontrak terbaru (${latestVersion.versionNumber}) belum memiliki BAK dan kontrak belum aktif.`,
        });
      }

      const invoicesWithoutUpload = currentInvoices.filter((invoice) => {
        const dueDate = toIsoDate(invoice.dueDate);
        if (invoice.invoiceFileUrl || !dueDate) {
          return false;
        }

        return addDays(dueDate, -7) <= today;
      });

      if (invoicesWithoutUpload.length > 0) {
        const nearestDueDate =
          invoicesWithoutUpload
            .map((invoice) => toIsoDate(invoice.dueDate))
            .filter((value): value is string => Boolean(value))
            .sort()[0] ?? null;

        alerts.push({
          customerId: customer.id,
          customerName: customer.name,
          code: 'invoice_not_uploaded',
          severity: 'medium',
          message: `${invoicesWithoutUpload.length} invoice mendekati jatuh tempo dan belum diunggah.${nearestDueDate ? ` Tenggat terdekat ${nearestDueDate}.` : ''}`,
        });
      }

      if (
        !customer.activationFeePaidAt &&
        Number(customer.activationFeeAmount ?? 0) > 0
      ) {
        alerts.push({
          customerId: customer.id,
          customerName: customer.name,
          code: 'activation_fee_unpaid',
          severity: 'medium',
          message: `Biaya aktivasi belum dibayar (Rp ${Number(
            customer.activationFeeAmount ?? 0,
          ).toLocaleString('id-ID')}).`,
        });
      }

      const hasTerminationDocument = customer.documents.some(
        (document) => document.jenisDokumen === 'pemutusan',
      );

      if (hasTerminationDocument) {
        alerts.push({
          customerId: customer.id,
          customerName: customer.name,
          code: 'has_termination_document',
          severity: 'low',
          message: 'Dokumen pemutusan ditemukan. Perlu verifikasi lanjutan.',
        });
      }
    });

    return alerts;
  }

  private buildPriorityAlerts(
    customerId: number,
    customerName: string,
    invoices: Array<{
      status: InvoiceStatus;
      dueDate: string | null;
      invoiceFileUrl: string | null;
      paymentProofFileUrl: string | null;
      amount: number;
    }>,
    activeVersion:
      | {
          endDate: string;
        }
      | undefined,
    referenceDate: string,
  ): MonitoringAlert[] {
    const alerts: MonitoringAlert[] = [];
    const nowDate = parseDate(referenceDate);

    if (activeVersion) {
      const daysLeft = Math.ceil(
        (parseDate(activeVersion.endDate).getTime() - nowDate.getTime()) /
          (24 * 60 * 60 * 1000),
      );

      if (daysLeft <= 90 && daysLeft >= 0) {
        alerts.push({
          customerId,
          customerName,
          code: 'contract_expiring',
          severity: 'medium',
          message: 'Kontrak akan habis, buat surat perpanjangan.',
        });
      }
    }

    const overdueInvoices = invoices.filter((invoice) => {
      if (!invoice.invoiceFileUrl) {
        return false;
      }

      if (invoice.status === InvoiceStatus.Terlambat) {
        return true;
      }

      if (
        invoice.status !== InvoiceStatus.Lunas &&
        invoice.dueDate &&
        invoice.dueDate < referenceDate
      ) {
        return true;
      }

      return false;
    });

    if (overdueInvoices.length > 0) {
      alerts.push({
        customerId,
        customerName,
        code: 'payment_overdue',
        severity: 'high',
        message: `${overdueInvoices.length} invoice overdue dan perlu follow-up pembayaran.`,
      });
    }

    return alerts;
  }

  private findActiveContractVersion(
    contractVersions: Array<{
      id: number;
      startDate: string;
      endDate: string;
      bakDocumentId: number | null;
    }>,
    contractStatus: ContractStatus | null,
    referenceDate: string,
  ) {
    if (contractStatus === ContractStatus.Terminated) {
      return undefined;
    }

    return contractVersions.find(
      (version) =>
        version.bakDocumentId !== null &&
        version.startDate <= referenceDate &&
        version.endDate >= referenceDate,
    );
  }

  private parseYear(value?: string): number {
    if (!value) {
      return new Date().getUTCFullYear();
    }

    const year = Number(value);
    if (!Number.isInteger(year) || year < 2000 || year > 2100) {
      throw new BadRequestException(
        'year must be a number between 2000 and 2100.',
      );
    }

    return year;
  }

  private parseInvoiceStatus(value?: string): InvoiceStatus | undefined {
    if (!value) {
      return undefined;
    }

    const validStatuses = Object.values(InvoiceStatus);
    if (!validStatuses.includes(value as InvoiceStatus)) {
      throw new BadRequestException(
        `status must be one of: ${validStatuses.join(', ')}`,
      );
    }

    return value as InvoiceStatus;
  }

  private buildSummary(rows: Array<{ months: InvoiceStatus[] }>) {
    const summary = {
      lunas: 0,
      belum_bayar: 0,
      terlambat: 0,
      belum_ditagih: 0,
    };

    rows.forEach((row) => {
      row.months.forEach((status) => {
        summary[status] += 1;
      });
    });

    return summary;
  }
}

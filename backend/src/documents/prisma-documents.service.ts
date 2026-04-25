import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  CoreAllocationType as PrismaCoreAllocationType,
  Prisma,
} from '@prisma/client';
import {
  ContractStatus,
  CoreAllocationType,
  CustomerStatus,
  DOCUMENT_TYPE_VALUES,
  DocumentRecord,
  DocumentType,
  InvoiceFollowUpSource,
  InvoiceFollowUpStatus,
  InvoiceStatus,
} from '../shared/types/domain.types';
import { PrismaService } from '../prisma/prisma.service';
import { CreateDocumentDto } from './dto/create-document.dto';
import { CreateDocumentResponse } from './documents.service';

type PrismaTx = Prisma.TransactionClient;
type PrismaExecutor = PrismaTx | PrismaService;
type DocumentDbRecord = Prisma.DocumentGetPayload<object>;
type InvoiceWithFollowUps = Prisma.InvoiceGetPayload<{
  include: {
    followUps: {
      orderBy: {
        splitOrder: 'asc';
      };
    };
  };
}>;
const REQUIRED_CONTRACT_REFERENCE_DOC_TYPES = [
  DocumentType.Penawaran,
  DocumentType.Tanggapan,
  DocumentType.HasilNego,
];

const toIsoDate = (value: Date | null | undefined): string | null =>
  value ? value.toISOString().slice(0, 10) : null;

const toIsoTimestamp = (value: Date | null | undefined): string | null =>
  value ? value.toISOString() : null;

const parseDate = (value: string): Date => new Date(`${value}T00:00:00.000Z`);

const addMonths = (value: string, months: number): string => {
  const next = parseDate(value);
  next.setUTCMonth(next.getUTCMonth() + months);
  return next.toISOString().slice(0, 10);
};

const addYears = (value: string, years: number): string => {
  const next = parseDate(value);
  next.setUTCFullYear(next.getUTCFullYear() + years);
  return next.toISOString().slice(0, 10);
};

const buildContractNumber = (
  contractId: number,
  contractYear: number,
): string => `CTR-${contractYear}-${String(contractId).padStart(4, '0')}`;

const buildInvoiceNumber = (
  customerCode: string,
  periodYear: number,
  periodMonth: number,
  invoiceId: number,
): string => {
  const compactCode = customerCode.replace('CUST-', '');
  return `INV-${periodYear}${String(periodMonth).padStart(2, '0')}-${compactCode}-${String(invoiceId).padStart(3, '0')}`;
};

@Injectable()
export class PrismaDocumentsService {
  constructor(private readonly prisma: PrismaService) {}

  isEnabled(): boolean {
    return this.prisma.isEnabled() && process.env.DOCUMENTS_SOURCE === 'prisma';
  }

  async listByCustomer(
    customerId: number,
    rawJenisDokumen?: string,
  ): Promise<DocumentRecord[]> {
    await this.ensureCustomerExists(this.prisma, customerId);

    const jenisDokumen = rawJenisDokumen
      ? this.parseDocumentType(rawJenisDokumen)
      : undefined;

    if (rawJenisDokumen && !jenisDokumen) {
      throw new BadRequestException(
        `jenisDokumen must be one of: ${DOCUMENT_TYPE_VALUES.join(', ')}`,
      );
    }

    const documents = await this.prisma.document.findMany({
      where: {
        customerId,
        ...(jenisDokumen ? { jenisDokumen } : {}),
      },
      orderBy: [{ tanggalDokumen: 'desc' }, { id: 'desc' }],
    });

    return documents.map((document) => this.mapDocumentRecord(document));
  }

  async getById(
    customerId: number,
    documentId: number,
  ): Promise<DocumentRecord> {
    await this.ensureCustomerExists(this.prisma, customerId);

    const document = await this.prisma.document.findFirst({
      where: {
        id: documentId,
        customerId,
      },
    });

    if (!document) {
      throw new NotFoundException('Document not found for this customer.');
    }

    return this.mapDocumentRecord(document);
  }

  async create(
    customerId: number,
    payload: CreateDocumentDto,
    file?: Express.Multer.File,
  ): Promise<CreateDocumentResponse> {
    this.validateCreatePayload(payload);

    const jenisDokumen = this.parseDocumentType(payload.jenisDokumen);
    if (!jenisDokumen) {
      throw new BadRequestException(
        `jenisDokumen must be one of: ${DOCUMENT_TYPE_VALUES.join(', ')}`,
      );
    }

    const tanggalDokumen = payload.tanggalDokumen?.trim()
      ? this.parseIsoDateString(payload.tanggalDokumen, 'tanggalDokumen')
      : new Date().toISOString().slice(0, 10);

    return this.prisma.$transaction(async (tx) => {
      await this.ensureCustomerExists(tx, customerId);

      const contract = await this.resolveContract(
        tx,
        customerId,
        payload.contractId,
      );
      const contractVersion = await this.resolveContractVersion(
        tx,
        customerId,
        contract?.id ?? null,
        payload.contractVersionId,
      );

      const contractNumber = contract?.contractNumber ?? null;

      if (
        REQUIRED_CONTRACT_REFERENCE_DOC_TYPES.includes(jenisDokumen) &&
        !contractNumber
      ) {
        throw new BadRequestException(
          'Dokumen wajib tenant harus mereferensikan nomor kontrak aktif.',
        );
      }

      if (jenisDokumen === DocumentType.BAK && !contractVersion) {
        throw new BadRequestException(
          'Dokumen BAK wajib terkait contract version.',
        );
      }

      const uploadedFileUrl = this.buildDataUrlFromUploadedFile(file);
      const normalizedFileUrl =
        typeof payload.fileUrl === 'string' && payload.fileUrl.trim().length > 0
          ? payload.fileUrl.trim()
          : (uploadedFileUrl ??
            this.buildGeneratedFileUrl(
              customerId,
              jenisDokumen,
              tanggalDokumen,
            ));

      const document = await tx.document.create({
        data: {
          customerId,
          contractId: contract?.id ?? null,
          contractVersionId: contractVersion?.id ?? null,
          contractNumber,
          jenisDokumen,
          nomorDokumen: payload.nomorDokumen?.trim() || null,
          tanggalDokumen: parseDate(tanggalDokumen),
          fileUrl: normalizedFileUrl,
        },
      });

      if (jenisDokumen === DocumentType.BAK && contractVersion) {
        await tx.contractVersion.update({
          where: { id: contractVersion.id },
          data: { bakDocumentId: document.id },
        });
        await this.refreshContractStatus(tx, contractVersion.contractId);
      }

      if (jenisDokumen === DocumentType.Invoice) {
        await this.linkInvoiceDocument(
          tx,
          customerId,
          document,
          payload,
          contractVersion?.id ?? null,
          contractNumber,
        );
      }

      const automation =
        jenisDokumen === DocumentType.Invoice
          ? {
              customerStatus: null,
              contractChanged: false,
              invoiceChanged: true,
              actions: [
                'Invoice tenant diperbarui berdasarkan dokumen upload.',
                'Status invoice dihitung otomatis dari file invoice dan bukti bayar.',
              ],
            }
          : jenisDokumen === DocumentType.BAK
            ? {
                customerStatus: null,
                contractChanged: true,
                invoiceChanged: false,
                actions: ['BAK terhubung ke contract version terkait.'],
              }
            : await this.applyAutomation(tx, this.mapDocumentRecord(document));

      return {
        document: this.mapDocumentRecord(document),
        automation,
      };
    });
  }

  async delete(
    customerId: number,
    documentId: number,
  ): Promise<{ deleted: boolean }> {
    return this.prisma.$transaction(async (tx) => {
      await this.ensureCustomerExists(tx, customerId);

      const document = await tx.document.findFirst({
        where: {
          id: documentId,
          customerId,
        },
      });

      if (!document) {
        throw new NotFoundException('Document not found for this customer.');
      }

      const impactedInvoices = await tx.invoice.findMany({
        where: { documentId },
        include: {
          followUps: {
            orderBy: { splitOrder: 'asc' },
          },
        },
      });

      const affectedContracts = new Set<number>();
      if (document.contractId) {
        affectedContracts.add(document.contractId);
      }

      const bakVersions = await tx.contractVersion.findMany({
        where: { bakDocumentId: documentId },
        select: { id: true, contractId: true },
      });
      bakVersions.forEach((version) =>
        affectedContracts.add(version.contractId),
      );

      await tx.document.delete({
        where: { id: documentId },
      });

      for (const invoice of impactedInvoices) {
        await tx.invoiceFollowUp.updateMany({
          where: { invoiceId: invoice.id },
          data: { invoiceFileUrl: null },
        });

        await tx.invoice.update({
          where: { id: invoice.id },
          data: {
            documentId: null,
            invoiceFileUrl: null,
            invoiceNumber: null,
          },
        });

        await this.syncInvoiceFollowUps(tx, invoice.id);
      }

      for (const contractId of affectedContracts) {
        await this.refreshContractStatus(tx, contractId);
      }

      return { deleted: true };
    });
  }

  private async linkInvoiceDocument(
    tx: PrismaTx,
    customerId: number,
    document: DocumentDbRecord,
    payload: CreateDocumentDto,
    contractVersionId: number | null,
    contractNumber: string | null,
  ): Promise<void> {
    const tanggalDokumen = this.toIsoDateRequired(document.tanggalDokumen);
    const periodYear = Number(tanggalDokumen.slice(0, 4));
    const periodMonth = Number(tanggalDokumen.slice(5, 7));

    const existingInvoice = payload.invoiceId
      ? await tx.invoice.findFirst({
          where: {
            id: Number(payload.invoiceId),
            customerId,
          },
          include: {
            followUps: {
              orderBy: { splitOrder: 'asc' },
            },
            customer: true,
          },
        })
      : await tx.invoice.findFirst({
          where: {
            customerId,
            periodYear,
            periodMonth,
            scheduleStatus: 'active',
          },
          orderBy: { id: 'desc' },
          include: {
            followUps: {
              orderBy: { splitOrder: 'asc' },
            },
            customer: true,
          },
        });

    const invoiceFileUrl =
      typeof payload.invoiceFileUrl === 'string'
        ? payload.invoiceFileUrl.trim().length > 0
          ? payload.invoiceFileUrl.trim()
          : null
        : (existingInvoice?.invoiceFileUrl ?? document.fileUrl);

    const hasIncomingPaymentProof =
      typeof payload.paymentProofFileUrl === 'string' &&
      payload.paymentProofFileUrl.trim().length > 0;

    const paymentProofFileUrl = hasIncomingPaymentProof
      ? payload.paymentProofFileUrl!.trim()
      : (existingInvoice?.paymentProofFileUrl ?? null);

    const targetAmount = Number(existingInvoice?.amount ?? 0);
    const dueDate =
      toIsoDate(existingInvoice?.dueDate) ?? this.shiftDate(tanggalDokumen, 10);

    const customer =
      existingInvoice?.customer ??
      (await tx.customer.findUnique({
        where: { id: customerId },
      }));

    if (!customer) {
      throw new NotFoundException('Customer not found.');
    }

    const invoiceNumberFromPayload = payload.nomorDokumen?.trim() || null;

    let invoiceId: number;

    if (existingInvoice) {
      const generatedInvoiceNumber = buildInvoiceNumber(
        customer.customerCode,
        periodYear,
        periodMonth,
        existingInvoice.id,
      );

      await tx.invoice.update({
        where: { id: existingInvoice.id },
        data: {
          customerId,
          contractId: document.contractId,
          contractVersionId,
          contractNumber,
          invoiceNumber:
            invoiceNumberFromPayload ??
            existingInvoice.invoiceNumber ??
            generatedInvoiceNumber,
          periodMonth,
          periodYear,
          periodStartDate:
            existingInvoice.periodStartDate ??
            parseDate(
              `${periodYear}-${String(periodMonth).padStart(2, '0')}-01`,
            ),
          periodEndDate:
            existingInvoice.periodEndDate ??
            parseDate(this.lastDayOfMonth(periodYear, periodMonth)),
          dueDate: parseDate(dueDate),
          amount: targetAmount,
          documentId: document.id,
          paidAt: paymentProofFileUrl
            ? new Date(
                `${
                  hasIncomingPaymentProof
                    ? tanggalDokumen
                    : (toIsoDate(existingInvoice.paidAt) ?? tanggalDokumen)
                }T00:00:00.000Z`,
              )
            : null,
          invoiceFileUrl,
          paymentProofFileUrl,
        },
      });

      invoiceId = existingInvoice.id;
    } else {
      const createdInvoice = await tx.invoice.create({
        data: {
          customerId,
          invoiceNumber: 'TMP-INVOICE',
          contractId: document.contractId,
          contractVersionId,
          contractNumber,
          periodMonth,
          periodYear,
          periodStartDate: parseDate(
            `${periodYear}-${String(periodMonth).padStart(2, '0')}-01`,
          ),
          periodEndDate: parseDate(
            this.lastDayOfMonth(periodYear, periodMonth),
          ),
          dueDate: parseDate(dueDate),
          amount: targetAmount,
          status: InvoiceStatus.BelumDitagih,
          scheduleVersion: 1,
          scheduleStatus: 'active',
          documentId: document.id,
          paidAt: paymentProofFileUrl
            ? new Date(`${tanggalDokumen}T00:00:00.000Z`)
            : null,
          invoiceFileUrl,
          paymentProofFileUrl,
        },
      });

      const invoiceNumber =
        invoiceNumberFromPayload ??
        buildInvoiceNumber(
          customer.customerCode,
          periodYear,
          periodMonth,
          createdInvoice.id,
        );

      await tx.invoice.update({
        where: { id: createdInvoice.id },
        data: { invoiceNumber },
      });

      invoiceId = createdInvoice.id;
    }

    await this.syncInvoiceFollowUps(tx, invoiceId);
  }

  private async syncInvoiceFollowUps(
    tx: PrismaTx,
    invoiceId: number,
  ): Promise<void> {
    const invoice = await tx.invoice.findUnique({
      where: { id: invoiceId },
      include: {
        followUps: {
          orderBy: { splitOrder: 'asc' },
        },
      },
    });

    if (!invoice) {
      return;
    }

    const hasLegacyUpload = Boolean(invoice.invoiceFileUrl);
    const hasUploadedFollowUp = invoice.followUps.some(
      (item) => item.invoiceFileUrl,
    );

    if (hasLegacyUpload && !hasUploadedFollowUp) {
      await tx.invoiceFollowUp.create({
        data: {
          invoiceId: invoice.id,
          splitOrder: 1,
          source: InvoiceFollowUpSource.Upload,
          triggerCode: 'legacy_initial',
          title: 'Invoice Awal',
          description:
            'Split awal hasil sinkronisasi dari data invoice yang sudah ada.',
          status: invoice.paymentProofFileUrl
            ? InvoiceFollowUpStatus.Completed
            : InvoiceFollowUpStatus.Sent,
          invoiceNumber: invoice.invoiceNumber ?? null,
          invoiceFileUrl: invoice.invoiceFileUrl ?? null,
        },
      });
    }

    const refreshedInvoice = await tx.invoice.findUnique({
      where: { id: invoiceId },
      include: {
        followUps: {
          orderBy: { splitOrder: 'asc' },
        },
      },
    });

    if (!refreshedInvoice) {
      return;
    }

    if (refreshedInvoice.paymentProofFileUrl) {
      await tx.invoiceFollowUp.updateMany({
        where: { invoiceId },
        data: { status: InvoiceFollowUpStatus.Completed },
      });

      await this.syncInvoiceMirrorFields(tx, invoiceId);
      return;
    }

    const hasInitialUpload = refreshedInvoice.followUps.some(
      (item) => item.invoiceFileUrl,
    );

    if (hasInitialUpload && refreshedInvoice.dueDate) {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const dueDate = refreshedInvoice.dueDate;
      const daysPastDue = Math.floor(
        (today.getTime() - dueDate.getTime()) / (24 * 60 * 60 * 1000),
      );

      await this.ensureAutoInvoiceFollowUp(
        tx,
        refreshedInvoice,
        daysPastDue,
        1,
        2,
        'auto_overdue_d1',
        'Peringatan Pertama',
        'Pembayaran melewati jatuh tempo. Unggah invoice peringatan pertama untuk tindak lanjut penagihan.',
      );
      await this.ensureAutoInvoiceFollowUp(
        tx,
        refreshedInvoice,
        daysPastDue,
        7,
        3,
        'auto_overdue_d7',
        'Peringatan Kedua',
        'Pembayaran belum diselesaikan lebih dari 7 hari setelah jatuh tempo. Lanjutkan dengan invoice peringatan berikutnya.',
      );
    }

    await this.syncInvoiceMirrorFields(tx, invoiceId);
  }

  private async ensureAutoInvoiceFollowUp(
    tx: PrismaTx,
    invoice: InvoiceWithFollowUps,
    daysPastDue: number,
    thresholdDays: number,
    splitOrder: number,
    triggerCode: string,
    title: string,
    description: string,
  ): Promise<void> {
    if (daysPastDue < thresholdDays) {
      return;
    }

    const alreadyHandled = invoice.followUps.some(
      (followUp) =>
        followUp.splitOrder >= splitOrder ||
        followUp.triggerCode === triggerCode,
    );

    if (alreadyHandled) {
      return;
    }

    await tx.invoiceFollowUp.create({
      data: {
        invoiceId: invoice.id,
        splitOrder,
        source: InvoiceFollowUpSource.Auto,
        triggerCode,
        title,
        description,
        status: InvoiceFollowUpStatus.Warning,
        invoiceNumber: null,
        invoiceFileUrl: null,
      },
    });
  }

  private async syncInvoiceMirrorFields(
    tx: PrismaTx,
    invoiceId: number,
  ): Promise<void> {
    const invoice = await tx.invoice.findUnique({
      where: { id: invoiceId },
      include: {
        followUps: {
          orderBy: { splitOrder: 'asc' },
        },
      },
    });

    if (!invoice) {
      return;
    }

    const latestWithInvoice = [...invoice.followUps]
      .filter((item) => item.invoiceFileUrl)
      .sort((left, right) => right.splitOrder - left.splitOrder)[0];

    if (invoice.paymentProofFileUrl) {
      await tx.invoiceFollowUp.updateMany({
        where: { invoiceId },
        data: { status: InvoiceFollowUpStatus.Completed },
      });
    } else {
      for (const followUp of invoice.followUps) {
        await tx.invoiceFollowUp.update({
          where: { id: followUp.id },
          data: {
            status: followUp.invoiceFileUrl
              ? InvoiceFollowUpStatus.Sent
              : followUp.status === 'completed'
                ? InvoiceFollowUpStatus.Completed
                : InvoiceFollowUpStatus.Warning,
          },
        });
      }
    }

    const nextStatus = this.deriveInvoiceStatus({
      paidAt: toIsoTimestamp(invoice.paidAt),
      paymentProofFileUrl: invoice.paymentProofFileUrl,
      invoiceFileUrl: latestWithInvoice?.invoiceFileUrl ?? null,
      dueDate: toIsoDate(invoice.dueDate),
    });

    await tx.invoice.update({
      where: { id: invoiceId },
      data: {
        invoiceNumber: latestWithInvoice?.invoiceNumber ?? null,
        invoiceFileUrl: latestWithInvoice?.invoiceFileUrl ?? null,
        status: nextStatus,
      },
    });
  }

  private async applyAutomation(tx: PrismaTx, document: DocumentRecord) {
    switch (document.jenisDokumen) {
      case DocumentType.Pemutusan:
        return this.handleTermination(tx, document);
      case DocumentType.Perpanjangan:
        return this.handleExtension(tx, document);
      case DocumentType.Kontrak:
        return this.handleContract(tx, document);
      default:
        return {
          customerStatus: null,
          contractChanged: false,
          invoiceChanged: false,
          actions: ['No automation rule for this document type.'],
        };
    }
  }

  private async handleTermination(tx: PrismaTx, document: DocumentRecord) {
    await tx.customer.update({
      where: { id: document.customerId },
      data: { status: CustomerStatus.Nonaktif },
    });

    const contract = await tx.contract.findFirst({
      where: { customerId: document.customerId },
      orderBy: { id: 'desc' },
    });

    if (!contract) {
      return {
        customerStatus: CustomerStatus.Nonaktif,
        contractChanged: false,
        invoiceChanged: false,
        actions: [
          'Customer status changed to nonaktif.',
          'No active contract found to terminate.',
          'Customer will not appear in active monitoring rows.',
        ],
      };
    }

    await tx.contract.update({
      where: { id: contract.id },
      data: {
        status: ContractStatus.Terminated,
        endDate: parseDate(document.tanggalDokumen),
      },
    });

    const latestVersion = await tx.contractVersion.findFirst({
      where: { contractId: contract.id },
      orderBy: { versionNumber: 'desc' },
    });

    if (
      latestVersion &&
      this.toIsoDateRequired(latestVersion.endDate) > document.tanggalDokumen
    ) {
      await tx.contractVersion.update({
        where: { id: latestVersion.id },
        data: { endDate: parseDate(document.tanggalDokumen) },
      });
    }

    return {
      customerStatus: CustomerStatus.Nonaktif,
      contractChanged: true,
      invoiceChanged: false,
      actions: [
        'Customer status changed to nonaktif.',
        '1 active contract(s) terminated.',
        'Customer will not appear in active monitoring rows.',
      ],
    };
  }

  private async handleExtension(tx: PrismaTx, document: DocumentRecord) {
    const contract = await tx.contract.findFirst({
      where: { customerId: document.customerId },
      orderBy: { id: 'desc' },
    });

    await tx.customer.update({
      where: { id: document.customerId },
      data: { status: CustomerStatus.Aktif },
    });

    if (!contract) {
      const createdContract = await this.createPrimaryContract(
        tx,
        document.customerId,
        document.tanggalDokumen,
        addMonths(document.tanggalDokumen, 12),
        {
          coreType: CoreAllocationType.Core,
          coreTotal: 4,
          sharingRatio: null,
          billingEvery: 1,
          billingUnit: 'bulan',
        },
      );

      await this.createContractVersion(tx, {
        contractId: createdContract.id,
        customerId: document.customerId,
        startDate: document.tanggalDokumen,
        endDate: addMonths(document.tanggalDokumen, 12),
        coreType: CoreAllocationType.Core,
        coreTotal: 4,
        sharedCoreRatio: null,
      });

      await this.refreshContractStatus(tx, createdContract.id);

      return {
        customerStatus: CustomerStatus.Aktif,
        contractChanged: true,
        invoiceChanged: false,
        actions: [
          'New contract created from extension document.',
          'Customer status kept as aktif.',
        ],
      };
    }

    const latestVersion = await tx.contractVersion.findFirst({
      where: { contractId: contract.id },
      orderBy: { versionNumber: 'desc' },
    });

    if (latestVersion) {
      const nextEndDate = addMonths(
        this.toIsoDateRequired(latestVersion.endDate),
        12,
      );

      await tx.contractVersion.update({
        where: { id: latestVersion.id },
        data: { endDate: parseDate(nextEndDate) },
      });

      await tx.contract.update({
        where: { id: contract.id },
        data: { endDate: parseDate(nextEndDate) },
      });
    } else {
      await this.createContractVersion(tx, {
        contractId: contract.id,
        customerId: document.customerId,
        startDate: document.tanggalDokumen,
        endDate: addMonths(document.tanggalDokumen, 12),
        coreType: contract.coreType,
        coreTotal: contract.coreTotal,
        sharedCoreRatio: contract.sharingRatio,
      });
    }

    await this.refreshContractStatus(tx, contract.id);

    return {
      customerStatus: CustomerStatus.Aktif,
      contractChanged: true,
      invoiceChanged: false,
      actions: [
        latestVersion
          ? 'Active contract end date extended by 12 months.'
          : 'New contract created from extension document.',
        'Customer status kept as aktif.',
      ],
    };
  }

  private async handleContract(tx: PrismaTx, document: DocumentRecord) {
    let contract = await tx.contract.findFirst({
      where: { customerId: document.customerId },
      orderBy: { id: 'desc' },
    });

    await tx.customer.update({
      where: { id: document.customerId },
      data: { status: CustomerStatus.Aktif },
    });

    if (!contract) {
      contract = await this.createPrimaryContract(
        tx,
        document.customerId,
        document.tanggalDokumen,
        addYears(document.tanggalDokumen, 1),
        {
          coreType: CoreAllocationType.Core,
          coreTotal: 4,
          sharingRatio: null,
          billingEvery: 1,
          billingUnit: 'bulan',
        },
      );
    }

    const latestVersion = await tx.contractVersion.findFirst({
      where: { contractId: contract.id },
      orderBy: { versionNumber: 'desc' },
    });

    await this.createContractVersion(tx, {
      contractId: contract.id,
      customerId: document.customerId,
      startDate: document.tanggalDokumen,
      endDate: addYears(document.tanggalDokumen, 1),
      coreType: latestVersion?.coreType ?? contract.coreType,
      coreTotal: latestVersion?.coreTotal ?? contract.coreTotal,
      sharedCoreRatio: latestVersion?.sharedCoreRatio ?? contract.sharingRatio,
    });

    await tx.contract.update({
      where: { id: contract.id },
      data: { endDate: parseDate(addYears(document.tanggalDokumen, 1)) },
    });

    await this.refreshContractStatus(tx, contract.id);

    return {
      customerStatus: CustomerStatus.Aktif,
      contractChanged: true,
      invoiceChanged: false,
      actions: [
        'Contract record created/revised from contract document.',
        'Customer status set to aktif.',
      ],
    };
  }

  private async createPrimaryContract(
    tx: PrismaTx,
    customerId: number,
    startDate: string,
    endDate: string,
    config: {
      coreType: CoreAllocationType | PrismaCoreAllocationType;
      coreTotal: number;
      sharingRatio: string | null;
      billingEvery: number;
      billingUnit: 'hari' | 'bulan' | 'tahun';
    },
  ) {
    const createdContract = await tx.contract.create({
      data: {
        customerId,
        contractNumber: `TMP-CTR-${Date.now()}-${Math.round(Math.random() * 1000)}`,
        startDate: parseDate(startDate),
        endDate: parseDate(endDate),
        coreType: config.coreType as PrismaCoreAllocationType,
        coreTotal: config.coreTotal,
        sharingRatio:
          config.coreType === CoreAllocationType.SharingCore
            ? (config.sharingRatio ?? '1:2')
            : null,
        status: ContractStatus.Expired,
        billingEvery: config.billingEvery,
        billingUnit: config.billingUnit,
      },
    });

    const contractNumber = buildContractNumber(
      createdContract.id,
      Number(startDate.slice(0, 4)),
    );

    return tx.contract.update({
      where: { id: createdContract.id },
      data: { contractNumber },
    });
  }

  private async createContractVersion(
    tx: PrismaTx,
    payload: {
      contractId: number;
      customerId: number;
      startDate: string;
      endDate: string;
      coreType: CoreAllocationType | PrismaCoreAllocationType;
      coreTotal: number;
      sharedCoreRatio: string | null;
    },
  ) {
    const latestVersion = await tx.contractVersion.findFirst({
      where: { contractId: payload.contractId },
      orderBy: { versionNumber: 'desc' },
    });

    return tx.contractVersion.create({
      data: {
        contractId: payload.contractId,
        customerId: payload.customerId,
        versionNumber: Number(latestVersion?.versionNumber ?? 0) + 1,
        startDate: parseDate(payload.startDate),
        endDate: parseDate(payload.endDate),
        coreType: payload.coreType as PrismaCoreAllocationType,
        coreTotal: payload.coreTotal,
        sharedCoreRatio: payload.sharedCoreRatio,
        bakDocumentId: null,
      },
    });
  }

  private async refreshContractStatus(
    tx: PrismaTx,
    contractId: number,
  ): Promise<void> {
    const contract = await tx.contract.findUnique({
      where: { id: contractId },
    });

    if (!contract || contract.status === 'terminated') {
      return;
    }

    const latestVersion = await tx.contractVersion.findFirst({
      where: { contractId },
      orderBy: { versionNumber: 'desc' },
    });

    if (!latestVersion) {
      await tx.contract.update({
        where: { id: contractId },
        data: { status: ContractStatus.Expired },
      });
      return;
    }

    const today = new Date().toISOString().slice(0, 10);
    const nextStatus =
      this.toIsoDateRequired(latestVersion.endDate) < today
        ? ContractStatus.Expired
        : latestVersion.bakDocumentId
          ? ContractStatus.Aktif
          : ContractStatus.Expired;

    await tx.contract.update({
      where: { id: contractId },
      data: { status: nextStatus },
    });
  }

  private async resolveContract(
    tx: PrismaTx,
    customerId: number,
    payloadContractId?: number | string | null,
  ) {
    if (payloadContractId === undefined || payloadContractId === null) {
      return tx.contract.findFirst({
        where: { customerId },
        orderBy: { id: 'desc' },
      });
    }

    const normalizedContractId = Number(payloadContractId);
    const matched = await tx.contract.findFirst({
      where: {
        id: normalizedContractId,
        customerId,
      },
    });

    if (!matched) {
      throw new BadRequestException(
        'contractId does not belong to the customer.',
      );
    }

    return matched;
  }

  private async resolveContractVersion(
    tx: PrismaTx,
    customerId: number,
    contractId: number | null,
    payloadContractVersionId?: number | string | null,
  ) {
    if (contractId === null) {
      return null;
    }

    if (
      payloadContractVersionId !== undefined &&
      payloadContractVersionId !== null
    ) {
      const matched = await tx.contractVersion.findFirst({
        where: {
          id: Number(payloadContractVersionId),
          customerId,
          contractId,
        },
      });

      if (!matched) {
        throw new BadRequestException(
          'contractVersionId does not belong to the provided contract/customer.',
        );
      }

      return matched;
    }

    return tx.contractVersion.findFirst({
      where: {
        customerId,
        contractId,
      },
      orderBy: { versionNumber: 'desc' },
    });
  }

  private async ensureCustomerExists(
    tx: PrismaExecutor,
    customerId: number,
  ): Promise<void> {
    const customer = await tx.customer.findUnique({
      where: { id: customerId },
      select: { id: true },
    });

    if (!customer) {
      throw new NotFoundException('Customer not found.');
    }
  }

  private mapDocumentRecord(document: DocumentDbRecord): DocumentRecord {
    return {
      id: document.id,
      customerId: document.customerId,
      contractId: document.contractId ?? null,
      contractVersionId: document.contractVersionId ?? null,
      contractNumber: document.contractNumber ?? null,
      jenisDokumen: document.jenisDokumen as DocumentType,
      nomorDokumen: document.nomorDokumen ?? null,
      tanggalDokumen: this.toIsoDateRequired(document.tanggalDokumen),
      fileUrl: document.fileUrl,
      createdAt: this.toIsoTimestampRequired(document.createdAt),
    };
  }

  private deriveInvoiceStatus(invoice: {
    paidAt?: string | null;
    paymentProofFileUrl?: string | null;
    invoiceFileUrl?: string | null;
    dueDate?: string | null;
  }): InvoiceStatus {
    const today = new Date().toISOString().slice(0, 10);

    if (invoice.paidAt && invoice.paymentProofFileUrl) {
      return InvoiceStatus.Lunas;
    }

    if (!invoice.invoiceFileUrl) {
      return InvoiceStatus.BelumDitagih;
    }

    if (invoice.dueDate && invoice.dueDate < today) {
      return InvoiceStatus.Terlambat;
    }

    return InvoiceStatus.BelumBayar;
  }

  private validateCreatePayload(payload: CreateDocumentDto): void {
    if (!payload || typeof payload !== 'object') {
      throw new BadRequestException('Request body is required.');
    }

    if (!payload.jenisDokumen) {
      throw new BadRequestException('jenisDokumen is required.');
    }

    if (
      payload.tanggalDokumen !== undefined &&
      payload.tanggalDokumen !== null &&
      payload.tanggalDokumen !== ''
    ) {
      this.parseIsoDateString(payload.tanggalDokumen, 'tanggalDokumen');
    }
  }

  private buildDataUrlFromUploadedFile(
    file?: Express.Multer.File,
  ): string | null {
    if (
      !file?.buffer ||
      !Buffer.isBuffer(file.buffer) ||
      file.buffer.length === 0
    ) {
      return null;
    }

    const mimeType =
      typeof file.mimetype === 'string' && file.mimetype.trim().length > 0
        ? file.mimetype.trim()
        : 'application/octet-stream';

    return `data:${mimeType};base64,${file.buffer.toString('base64')}`;
  }

  private parseIsoDateString(value: string, fieldName: string): string {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) {
      throw new BadRequestException(
        `${fieldName} must be in YYYY-MM-DD format.`,
      );
    }

    const parsedDate = new Date(`${value}T00:00:00.000Z`);
    if (Number.isNaN(parsedDate.getTime())) {
      throw new BadRequestException(`${fieldName} is invalid.`);
    }

    return value;
  }

  private parseDocumentType(value: string): DocumentType | undefined {
    return (DOCUMENT_TYPE_VALUES as readonly string[]).find(
      (type) => type === value,
    ) as DocumentType | undefined;
  }

  private buildGeneratedFileUrl(
    customerId: number,
    jenisDokumen: DocumentType,
    tanggalDokumen: string,
  ): string {
    const compactDate = tanggalDokumen.replaceAll('-', '');
    const token = Date.now().toString(36);
    return `internal://customer-${customerId}/${jenisDokumen}/${compactDate}-${token}.pdf`;
  }

  private shiftDate(value: string, days: number): string {
    const next = new Date(`${value}T00:00:00.000Z`);
    next.setUTCDate(next.getUTCDate() + days);
    return next.toISOString().slice(0, 10);
  }

  private lastDayOfMonth(year: number, month: number): string {
    return new Date(Date.UTC(year, month, 0)).toISOString().slice(0, 10);
  }

  private toIsoDateRequired(value: Date | null | undefined): string {
    const resolved = toIsoDate(value);
    if (!resolved) {
      throw new Error('Expected date value to be present.');
    }
    return resolved;
  }

  private toIsoTimestampRequired(value: Date | null | undefined): string {
    const resolved = toIsoTimestamp(value);
    if (!resolved) {
      throw new Error('Expected timestamp value to be present.');
    }
    return resolved;
  }
}

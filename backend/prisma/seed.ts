import 'dotenv/config';
import {
  BillingUnit,
  ContractStatus,
  CoreAllocationType,
  CustomerStatus,
  DocumentType,
  InvoiceFollowUpSource,
  InvoiceFollowUpStatus,
  InvoiceScheduleStatus,
  InvoiceStatus,
  IspPackageType,
  IspRenewalFollowUpSource,
  IspRenewalFollowUpStatus,
  IspRenewalResponseDecision,
  IspRenewalStatus,
  IspStatus,
  PrismaClient,
  RouteChangeMode,
  RouteFlowStatus,
  RouteHistoryOperation,
  RoutePointType,
} from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';

const connectionString = process.env.DATABASE_URL?.trim();

if (!connectionString) {
  throw new Error('DATABASE_URL is required to run prisma seed.');
}

const prisma = new PrismaClient({
  adapter: new PrismaPg({ connectionString }),
});

const forceReset = process.env.SEED_FORCE_RESET === 'true';
const currentDate = new Date();
const currentYear = currentDate.getUTCFullYear();
const currentMonth = currentDate.getUTCMonth() + 1;
const previousMonth = currentMonth === 1 ? 12 : currentMonth - 1;
const previousMonthYear = currentMonth === 1 ? currentYear - 1 : currentYear;

const dateOnly = (year: number, month: number, day: number) =>
  new Date(Date.UTC(year, month - 1, day));

const isoTimestamp = (
  year: number,
  month: number,
  day: number,
  hour = 0,
  minute = 0,
) => new Date(Date.UTC(year, month - 1, day, hour, minute));

async function clearTables() {
  await prisma.invoiceFollowUp.deleteMany();
  await prisma.invoice.deleteMany();
  await prisma.document.deleteMany();
  await prisma.contractVersionRenewalFollowUp.deleteMany();
  await prisma.contractVersion.deleteMany();
  await prisma.contract.deleteMany();
  await prisma.customerRouteHistory.deleteMany();
  await prisma.customerRoutePoint.deleteMany();
  await prisma.customerRouteVersion.deleteMany();
  await prisma.ispRenewalFollowUp.deleteMany();
  await prisma.ispContractRow.deleteMany();
  await prisma.customerIspMembership.deleteMany();
  await prisma.customer.deleteMany();
  await prisma.isp.deleteMany();
}

async function ensureSafeBootstrap() {
  const [customerCount, ispCount, contractCount, documentCount, invoiceCount] =
    await Promise.all([
      prisma.customer.count(),
      prisma.isp.count(),
      prisma.contract.count(),
      prisma.document.count(),
      prisma.invoice.count(),
    ]);

  const existingRows =
    customerCount + ispCount + contractCount + documentCount + invoiceCount;

  if (existingRows === 0) {
    return;
  }

  if (!forceReset) {
    console.log(
      'Seed skipped because database already contains data. Re-run with SEED_FORCE_RESET=true to replace bootstrap data.',
    );
    process.exit(0);
  }

  await clearTables();
}

async function seed() {
  await ensureSafeBootstrap();

  const primaryIsp = await prisma.isp.create({
    data: {
      name: 'PT Telkom Akses',
      status: IspStatus.aktif,
      contractReference: `ISP-TELKOM-${currentYear}`,
      contractStartDate: dateOnly(currentYear, 1, 1),
      contractPeriodStart: dateOnly(currentYear, 1, 1),
      contractPeriodEnd: dateOnly(currentYear, 12, 31),
      paket: IspPackageType.shared,
      jumlah: 2,
      billingPeriodMode: 'monthly',
      activationFeeAmount: '2500000',
      activationFeePaidAt: isoTimestamp(currentYear, 1, 5, 9, 0),
    },
  });

  const backupIsp = await prisma.isp.create({
    data: {
      name: 'Biznet Dedicated',
      status: IspStatus.aktif,
      contractReference: `ISP-BIZNET-${currentYear}`,
      contractStartDate: dateOnly(currentYear, 2, 1),
      contractPeriodStart: dateOnly(currentYear, 2, 1),
      contractPeriodEnd: dateOnly(currentYear, 12, 31),
      paket: IspPackageType.core,
      jumlah: 4,
      billingPeriodMode: 'monthly',
      activationFeeAmount: '4000000',
    },
  });

  const activeCustomer = await prisma.customer.create({
    data: {
      customerCode: 'CUST-001',
      ispName: primaryIsp.name,
      name: 'Dinas Kelautan Makassar',
      status: CustomerStatus.aktif,
      activationFeeAmount: '1500000',
      activationFeePaidAt: isoTimestamp(currentYear, 1, 7, 8, 30),
    },
  });

  const warningCustomer = await prisma.customer.create({
    data: {
      customerCode: 'CUST-002',
      ispName: backupIsp.name,
      name: 'UPTD Pelabuhan Paotere',
      status: CustomerStatus.aktif,
      activationFeeAmount: '1800000',
    },
  });

  await prisma.customerIspMembership.createMany({
    data: [
      { customerId: activeCustomer.id, ispId: primaryIsp.id },
      { customerId: warningCustomer.id, ispId: backupIsp.id },
    ],
  });

  const activeContract = await prisma.contract.create({
    data: {
      customerId: activeCustomer.id,
      contractNumber: `CTR-${currentYear}-0001`,
      startDate: dateOnly(currentYear, 1, 1),
      endDate: dateOnly(currentYear, 12, 31),
      coreType: CoreAllocationType.sharing_core,
      coreTotal: 2,
      sharingRatio: '1:2',
      status: ContractStatus.aktif,
      billingEvery: 1,
      billingUnit: BillingUnit.bulan,
    },
  });

  const warningContract = await prisma.contract.create({
    data: {
      customerId: warningCustomer.id,
      contractNumber: `CTR-${currentYear}-0002`,
      startDate: dateOnly(currentYear, 2, 1),
      endDate: dateOnly(currentYear, 11, 30),
      coreType: CoreAllocationType.core,
      coreTotal: 4,
      status: ContractStatus.aktif,
      billingEvery: 1,
      billingUnit: BillingUnit.bulan,
    },
  });

  const activeVersion = await prisma.contractVersion.create({
    data: {
      contractId: activeContract.id,
      customerId: activeCustomer.id,
      versionNumber: 1,
      startDate: dateOnly(currentYear, 1, 1),
      endDate: dateOnly(currentYear, 12, 31),
      coreType: CoreAllocationType.sharing_core,
      coreTotal: 2,
      sharedCoreRatio: '1:2',
      renewalFileUrl: 'https://files.example.com/contracts/renewal-cust-001.pdf',
      renewalFileName: 'renewal-cust-001.pdf',
      responseFileUrl: 'https://files.example.com/contracts/response-cust-001.pdf',
      responseFileName: 'response-cust-001.pdf',
    },
  });

  const warningVersion = await prisma.contractVersion.create({
    data: {
      contractId: warningContract.id,
      customerId: warningCustomer.id,
      versionNumber: 1,
      startDate: dateOnly(currentYear, 2, 1),
      endDate: dateOnly(currentYear, 11, 30),
      coreType: CoreAllocationType.core,
      coreTotal: 4,
      renewalFileUrl: 'https://files.example.com/contracts/renewal-cust-002.pdf',
      renewalFileName: 'renewal-cust-002.pdf',
    },
  });

  const activeContractDoc = await prisma.document.create({
    data: {
      customerId: activeCustomer.id,
      contractId: activeContract.id,
      contractVersionId: activeVersion.id,
      contractNumber: activeContract.contractNumber,
      jenisDokumen: DocumentType.kontrak,
      nomorDokumen: `DOC-CONTRACT-${currentYear}-001`,
      tanggalDokumen: dateOnly(currentYear, 1, 1),
      fileUrl: 'https://files.example.com/documents/contract-cust-001.pdf',
    },
  });

  const activeBakDoc = await prisma.document.create({
    data: {
      customerId: activeCustomer.id,
      contractId: activeContract.id,
      contractVersionId: activeVersion.id,
      contractNumber: activeContract.contractNumber,
      jenisDokumen: DocumentType.BAK,
      nomorDokumen: `DOC-BAK-${currentYear}-001`,
      tanggalDokumen: dateOnly(currentYear, currentMonth, 2),
      fileUrl: 'https://files.example.com/documents/bak-cust-001.pdf',
    },
  });

  const warningOfferDoc = await prisma.document.create({
    data: {
      customerId: warningCustomer.id,
      contractId: warningContract.id,
      contractVersionId: warningVersion.id,
      contractNumber: warningContract.contractNumber,
      jenisDokumen: DocumentType.penawaran,
      nomorDokumen: `DOC-OFFER-${currentYear}-002`,
      tanggalDokumen: dateOnly(currentYear, 2, 1),
      fileUrl: 'https://files.example.com/documents/offer-cust-002.pdf',
    },
  });

  await prisma.contractVersion.update({
    where: { id: activeVersion.id },
    data: { bakDocumentId: activeBakDoc.id },
  });

  const paidInvoiceDocument = await prisma.document.create({
    data: {
      customerId: activeCustomer.id,
      contractId: activeContract.id,
      contractVersionId: activeVersion.id,
      contractNumber: activeContract.contractNumber,
      jenisDokumen: DocumentType.invoice,
      nomorDokumen: `INV-DOC-${previousMonthYear}${String(previousMonth).padStart(2, '0')}-001`,
      tanggalDokumen: dateOnly(previousMonthYear, previousMonth, 1),
      fileUrl: 'https://files.example.com/documents/invoice-cust-001-prev.pdf',
    },
  });

  const paidInvoice = await prisma.invoice.create({
    data: {
      customerId: activeCustomer.id,
      invoiceNumber: `INV-${previousMonthYear}${String(previousMonth).padStart(2, '0')}-001`,
      contractId: activeContract.id,
      contractVersionId: activeVersion.id,
      contractNumber: activeContract.contractNumber,
      periodMonth: previousMonth,
      periodYear: previousMonthYear,
      periodStartDate: dateOnly(previousMonthYear, previousMonth, 1),
      periodEndDate: dateOnly(previousMonthYear, previousMonth, 28),
      dueDate: dateOnly(previousMonthYear, previousMonth, 10),
      amount: '2750000',
      status: InvoiceStatus.lunas,
      scheduleVersion: 1,
      scheduleStatus: InvoiceScheduleStatus.active,
      documentId: paidInvoiceDocument.id,
      paidAt: isoTimestamp(previousMonthYear, previousMonth, 9, 10, 15),
      invoiceFileUrl: 'https://files.example.com/invoices/invoice-cust-001-prev.pdf',
      paymentProofFileUrl: 'https://files.example.com/invoices/payment-proof-cust-001-prev.pdf',
    },
  });

  const currentInvoiceDocument = await prisma.document.create({
    data: {
      customerId: activeCustomer.id,
      contractId: activeContract.id,
      contractVersionId: activeVersion.id,
      contractNumber: activeContract.contractNumber,
      jenisDokumen: DocumentType.invoice,
      nomorDokumen: `INV-DOC-${currentYear}${String(currentMonth).padStart(2, '0')}-001`,
      tanggalDokumen: dateOnly(currentYear, currentMonth, 1),
      fileUrl: 'https://files.example.com/documents/invoice-cust-001-current.pdf',
    },
  });

  const currentInvoice = await prisma.invoice.create({
    data: {
      customerId: activeCustomer.id,
      invoiceNumber: `INV-${currentYear}${String(currentMonth).padStart(2, '0')}-001`,
      contractId: activeContract.id,
      contractVersionId: activeVersion.id,
      contractNumber: activeContract.contractNumber,
      periodMonth: currentMonth,
      periodYear: currentYear,
      periodStartDate: dateOnly(currentYear, currentMonth, 1),
      periodEndDate: dateOnly(currentYear, currentMonth, 28),
      dueDate: dateOnly(currentYear, currentMonth, 10),
      amount: '2750000',
      status: InvoiceStatus.belum_bayar,
      scheduleVersion: 1,
      scheduleStatus: InvoiceScheduleStatus.active,
      documentId: currentInvoiceDocument.id,
      invoiceFileUrl: 'https://files.example.com/invoices/invoice-cust-001-current.pdf',
    },
  });

  const warningInvoice = await prisma.invoice.create({
    data: {
      customerId: warningCustomer.id,
      invoiceNumber: `INV-${currentYear}${String(currentMonth).padStart(2, '0')}-002`,
      contractId: warningContract.id,
      contractVersionId: warningVersion.id,
      contractNumber: warningContract.contractNumber,
      periodMonth: currentMonth,
      periodYear: currentYear,
      periodStartDate: dateOnly(currentYear, currentMonth, 1),
      periodEndDate: dateOnly(currentYear, currentMonth, 28),
      dueDate: dateOnly(currentYear, currentMonth, 10),
      amount: '4250000',
      status: InvoiceStatus.terlambat,
      scheduleVersion: 1,
      scheduleStatus: InvoiceScheduleStatus.active,
      invoiceFileUrl: 'https://files.example.com/invoices/invoice-cust-002-current.pdf',
    },
  });

  await prisma.invoiceFollowUp.createMany({
    data: [
      {
        invoiceId: currentInvoice.id,
        splitOrder: 1,
        source: InvoiceFollowUpSource.auto,
        triggerCode: 'payment-reminder',
        title: 'Pengingat pembayaran berjalan',
        description:
          'Invoice bulan berjalan sudah diterbitkan tetapi bukti pembayaran belum masuk.',
        status: InvoiceFollowUpStatus.warning,
        invoiceNumber: currentInvoice.invoiceNumber,
        invoiceFileUrl: currentInvoice.invoiceFileUrl,
      },
      {
        invoiceId: warningInvoice.id,
        splitOrder: 1,
        source: InvoiceFollowUpSource.manual,
        triggerCode: 'late-payment',
        title: 'Tindak lanjut keterlambatan invoice',
        description:
          'Pelanggan perlu dihubungi karena invoice bulan berjalan melewati jatuh tempo.',
        status: InvoiceFollowUpStatus.sent,
        invoiceNumber: warningInvoice.invoiceNumber,
        invoiceFileUrl: warningInvoice.invoiceFileUrl,
      },
      {
        invoiceId: paidInvoice.id,
        splitOrder: 1,
        source: InvoiceFollowUpSource.auto,
        triggerCode: 'payment-complete',
        title: 'Pembayaran bulan lalu selesai',
        description: 'Invoice bulan sebelumnya sudah lunas dan arsip lengkap.',
        status: InvoiceFollowUpStatus.completed,
        invoiceNumber: paidInvoice.invoiceNumber,
        invoiceFileUrl: paidInvoice.invoiceFileUrl,
      },
    ],
  });

  const primaryIspContractRow = await prisma.ispContractRow.create({
    data: {
      ispId: primaryIsp.id,
      contractReference: primaryIsp.contractReference ?? `ISP-TELKOM-${currentYear}`,
      periodStart: dateOnly(currentYear, 1, 1),
      periodEnd: dateOnly(currentYear, 12, 31),
      renewalStatus: IspRenewalStatus.renewed,
      bakFileUrl: 'https://files.example.com/isps/bak-telkom.pdf',
      bakFileName: 'bak-telkom.pdf',
      renewalFileUrl: 'https://files.example.com/isps/renewal-telkom.pdf',
      renewalFileName: 'renewal-telkom.pdf',
      responseFileUrl: 'https://files.example.com/isps/response-telkom.pdf',
      responseFileName: 'response-telkom.pdf',
    },
  });

  const backupIspContractRow = await prisma.ispContractRow.create({
    data: {
      ispId: backupIsp.id,
      contractReference: backupIsp.contractReference ?? `ISP-BIZNET-${currentYear}`,
      periodStart: dateOnly(currentYear, 2, 1),
      periodEnd: dateOnly(currentYear, 12, 31),
      renewalStatus: IspRenewalStatus.pending,
      renewalFileUrl: 'https://files.example.com/isps/renewal-biznet.pdf',
      renewalFileName: 'renewal-biznet.pdf',
    },
  });

  await prisma.ispRenewalFollowUp.createMany({
    data: [
      {
        rowId: primaryIspContractRow.id,
        splitOrder: 1,
        source: IspRenewalFollowUpSource.upload,
        triggerCode: 'renewed',
        title: 'Perpanjangan ISP selesai',
        description: 'Dokumen renewal, response, dan BAK sudah lengkap.',
        status: IspRenewalFollowUpStatus.completed,
        renewalFileUrl: primaryIspContractRow.renewalFileUrl,
        renewalFileName: primaryIspContractRow.renewalFileName,
        responseFileUrl: primaryIspContractRow.responseFileUrl,
        responseFileName: primaryIspContractRow.responseFileName,
        responseDecision: IspRenewalResponseDecision.lanjut,
      },
      {
        rowId: backupIspContractRow.id,
        splitOrder: 1,
        source: IspRenewalFollowUpSource.manual,
        triggerCode: 'pending-response',
        title: 'Menunggu balasan ISP',
        description:
          'Dokumen renewal sudah dikirim, tetapi belum ada tanggapan resmi dari ISP.',
        status: IspRenewalFollowUpStatus.pending_response,
        renewalFileUrl: backupIspContractRow.renewalFileUrl,
        renewalFileName: backupIspContractRow.renewalFileName,
      },
    ],
  });

  await prisma.contractVersionRenewalFollowUp.createMany({
    data: [
      {
        versionId: activeVersion.id,
        splitOrder: 1,
        source: IspRenewalFollowUpSource.upload,
        triggerCode: 'completed',
        title: 'Renewal tenant lengkap',
        description: 'Renewal tenant sudah mendapat response dan BAK.',
        status: IspRenewalFollowUpStatus.completed,
        renewalFileUrl: activeVersion.renewalFileUrl,
        renewalFileName: activeVersion.renewalFileName,
        responseFileUrl: activeVersion.responseFileUrl,
        responseFileName: activeVersion.responseFileName,
        responseDecision: IspRenewalResponseDecision.lanjut,
      },
      {
        versionId: warningVersion.id,
        splitOrder: 1,
        source: IspRenewalFollowUpSource.manual,
        triggerCode: 'pending',
        title: 'Renewal tenant perlu tindak lanjut',
        description:
          'Kontrak tenant mendekati akhir periode dan dokumen BAK belum tersedia.',
        status: IspRenewalFollowUpStatus.warning,
        renewalFileUrl: warningVersion.renewalFileUrl,
        renewalFileName: warningVersion.renewalFileName,
      },
    ],
  });

  const activeRouteVersion = await prisma.customerRouteVersion.create({
    data: {
      customerId: activeCustomer.id,
      versionNumber: 1,
      flowStatus: RouteFlowStatus.aktif,
      changeMode: RouteChangeMode.initial,
      changeNote: 'Aktivasi awal jalur tenant.',
    },
  });

  const warningRouteVersion = await prisma.customerRouteVersion.create({
    data: {
      customerId: warningCustomer.id,
      versionNumber: 1,
      flowStatus: RouteFlowStatus.gangguan,
      changeMode: RouteChangeMode.initial,
      changeNote: 'Jalur aktif tetapi sedang menunggu stabilisasi perangkat.',
    },
  });

  await prisma.customerRoutePoint.createMany({
    data: [
      {
        routeVersionId: activeRouteVersion.id,
        orderNumber: 1,
        pathName: 'POP Panakkukang',
        pointType: RoutePointType.awal,
      },
      {
        routeVersionId: activeRouteVersion.id,
        orderNumber: 2,
        pathName: 'ODC Karebosi',
        pointType: RoutePointType.transit,
      },
      {
        routeVersionId: activeRouteVersion.id,
        orderNumber: 3,
        pathName: 'Kantor Dinas Kelautan',
        pointType: RoutePointType.tujuan,
      },
      {
        routeVersionId: warningRouteVersion.id,
        orderNumber: 1,
        pathName: 'POP Soekarno Hatta',
        pointType: RoutePointType.awal,
      },
      {
        routeVersionId: warningRouteVersion.id,
        orderNumber: 2,
        pathName: 'Pelabuhan Paotere',
        pointType: RoutePointType.tujuan,
      },
    ],
  });

  await prisma.customerRouteHistory.createMany({
    data: [
      {
        customerId: activeCustomer.id,
        operation: RouteHistoryOperation.commit,
        note: 'Jalur awal tenant disimpan.',
        snapshotBefore: { points: [] },
        snapshotAfter: {
          versionId: activeRouteVersion.id,
          points: ['POP Panakkukang', 'ODC Karebosi', 'Kantor Dinas Kelautan'],
        },
      },
      {
        customerId: warningCustomer.id,
        operation: RouteHistoryOperation.status,
        note: 'Jalur tenant ditandai gangguan untuk tindak lanjut lapangan.',
        snapshotBefore: { flowStatus: 'aktif' },
        snapshotAfter: { flowStatus: 'gangguan' },
      },
    ],
  });

  console.log(
    `Seed completed: customers=${2}, isps=${2}, contracts=${2}, documents=${5}, invoices=${3}.`,
  );
}

seed()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

import { Injectable } from '@nestjs/common';
import {
  CustomerStatus,
  DocumentRecord,
  DocumentType,
  InvoiceStatus,
} from '../shared/types/domain.types';
import { InMemoryDataService } from '../store/in-memory-data.service';

export interface DocumentAutomationResult {
  customerStatus: CustomerStatus | null;
  contractChanged: boolean;
  invoiceChanged: boolean;
  actions: string[];
}

@Injectable()
export class DocumentAutomationService {
  constructor(private readonly store: InMemoryDataService) { }

  apply(document: DocumentRecord): DocumentAutomationResult {
    switch (document.jenisDokumen) {
      case DocumentType.Pemutusan:
        return this.handleTermination(document);
      case DocumentType.Perpanjangan:
        return this.handleExtension(document);
      case DocumentType.Kontrak:
        return this.handleContract(document);
      case DocumentType.Invoice:
        return this.handleInvoice(document);
      default:
        return {
          customerStatus: null,
          contractChanged: false,
          invoiceChanged: false,
          actions: ['No automation rule for this document type.'],
        };
    }
  }

  private handleTermination(document: DocumentRecord): DocumentAutomationResult {
    this.store.updateCustomerStatus(document.customerId, CustomerStatus.Nonaktif);
    const terminatedContracts = this.store.terminateActiveContracts(
      document.customerId,
      document.tanggalDokumen,
    );

    return {
      customerStatus: CustomerStatus.Nonaktif,
      contractChanged: terminatedContracts.length > 0,
      invoiceChanged: false,
      actions: [
        'Customer status changed to nonaktif.',
        terminatedContracts.length > 0
          ? `${terminatedContracts.length} active contract(s) terminated.`
          : 'No active contract found to terminate.',
        'Customer will not appear in active monitoring rows.',
      ],
    };
  }

  private handleExtension(document: DocumentRecord): DocumentAutomationResult {
    const extension = this.store.extendActiveContract(
      document.customerId,
      12,
      document.tanggalDokumen,
    );

    this.store.updateCustomerStatus(document.customerId, CustomerStatus.Aktif);

    return {
      customerStatus: CustomerStatus.Aktif,
      contractChanged: true,
      invoiceChanged: false,
      actions: [
        extension.created
          ? 'New contract created from extension document.'
          : 'Active contract end date extended by 12 months.',
        'Customer status kept as aktif.',
      ],
    };
  }

  private handleContract(document: DocumentRecord): DocumentAutomationResult {
    this.store.createContractRevision(document.customerId, document.tanggalDokumen);
    this.store.updateCustomerStatus(document.customerId, CustomerStatus.Aktif);

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

  private handleInvoice(document: DocumentRecord): DocumentAutomationResult {
    const [periodYearRaw, periodMonthRaw] = document.tanggalDokumen.split('-');
    const periodYear = Number(periodYearRaw);
    const periodMonth = Number(periodMonthRaw);
    const activeContract = this.store.getActiveContract(
      document.customerId,
      document.tanggalDokumen,
    );

    this.store.upsertInvoice({
      customerId: document.customerId,
      contractId: activeContract?.id ?? null,
      invoiceNumber: document.nomorDokumen,
      periodMonth,
      periodYear,
      amount: 0,
      status: InvoiceStatus.BelumBayar,
      documentId: document.id,
    });

    return {
      customerStatus: null,
      contractChanged: false,
      invoiceChanged: true,
      actions: [
        'Invoice projection added/updated for monitoring billing matrix.',
        'Default invoice status set to belum_bayar.',
      ],
    };
  }
}

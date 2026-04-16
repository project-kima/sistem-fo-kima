import { DocumentType } from '../../shared/types/domain.types';

export class CreateDocumentDto {
  jenisDokumen!: DocumentType;
  nomorDokumen?: string;
  tanggalDokumen?: string;
  fileUrl?: string;
  contractId?: number | null;
  contractVersionId?: number | null;
  invoiceId?: number | null;
  invoiceFileUrl?: string | null;
  paymentProofFileUrl?: string | null;
}

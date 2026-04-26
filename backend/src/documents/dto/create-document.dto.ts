import {
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
} from 'class-validator';
import { DocumentType } from '../../shared/types/domain.types';

export class CreateDocumentDto {
  @IsEnum(DocumentType)
  jenisDokumen!: DocumentType;

  @IsOptional()
  @IsString()
  nomorDokumen?: string;

  @IsOptional()
  @IsDateString()
  tanggalDokumen?: string;

  @IsOptional()
  @IsString()
  fileUrl?: string;

  @IsOptional()
  @IsInt()
  contractId?: number | null;

  @IsOptional()
  @IsInt()
  contractVersionId?: number | null;

  @IsOptional()
  @IsInt()
  invoiceId?: number | null;

  @IsOptional()
  @IsString()
  invoiceFileUrl?: string | null;

  @IsOptional()
  @IsString()
  paymentProofFileUrl?: string | null;
}

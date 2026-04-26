import { Type } from 'class-transformer';
import {
  IsArray,
  IsDateString,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';

export class InvoiceFollowUpUpdateDto {
  @IsInt()
  id!: number;

  @IsOptional()
  @IsString()
  invoiceNumber?: string | null;
}

export class UpdateCustomerInvoiceDto {
  @IsOptional()
  @IsString()
  invoiceNumber?: string | null;

  @IsOptional()
  @IsInt()
  followUpId?: number | null;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => InvoiceFollowUpUpdateDto)
  invoiceFollowUps?: InvoiceFollowUpUpdateDto[];

  @IsOptional()
  @IsDateString()
  periodStartDate?: string | null;

  @IsOptional()
  @IsDateString()
  periodEndDate?: string | null;

  @IsOptional()
  @IsDateString()
  dueDate?: string | null;

  @IsOptional()
  @IsNumber()
  amount?: number;

  @IsOptional()
  @IsDateString()
  paidAt?: string | null;

  @IsOptional()
  @IsString()
  invoiceFileUrl?: string | null;

  @IsOptional()
  @IsString()
  paymentProofFileUrl?: string | null;
}

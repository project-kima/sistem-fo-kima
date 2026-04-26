import { Type } from 'class-transformer';
import {
  IsArray,
  IsDateString,
  IsEnum,
  IsIn,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { BillingUnit, CustomerStatus } from '../../shared/types/domain.types';

export class CreateInvoiceDraftDto {
  @IsDateString()
  periodStartDate!: string;

  @IsDateString()
  periodEndDate!: string;

  @IsOptional()
  @IsString()
  invoiceNumber?: string;

  @IsNumber()
  amount!: number;

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

export class CreateCustomerDto {
  @IsString()
  name!: string;

  @IsString()
  ispName!: string;

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  ispIds?: number[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  newIspNames?: string[];

  @IsOptional()
  @IsEnum(CustomerStatus)
  status?: CustomerStatus;

  @IsOptional()
  @IsNumber()
  activationFeeAmount?: number;

  @IsOptional()
  @IsDateString()
  activationFeePaidAt?: string | null;

  @IsOptional()
  @IsString()
  contractNumber?: string | null;

  @IsOptional()
  @IsDateString()
  contractStartDate?: string | null;

  @IsOptional()
  @IsDateString()
  contractEndDate?: string | null;

  @IsOptional()
  @IsIn(['core', 'shared'])
  paket?: 'core' | 'shared';

  @IsOptional()
  @IsInt()
  jumlah?: number;

  @IsOptional()
  @IsInt()
  contractCoreTotal?: number;

  @IsOptional()
  @IsString()
  contractSharingRatio?: string;

  @IsOptional()
  @IsIn(['bulanan', '3bulanan', 'custom'])
  billingPeriodMode?: 'bulanan' | '3bulanan' | 'custom';

  @IsOptional()
  @IsInt()
  billingCustomEvery?: number;

  @IsOptional()
  @IsEnum(BillingUnit)
  billingCustomUnit?: BillingUnit;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateInvoiceDraftDto)
  invoiceDrafts?: CreateInvoiceDraftDto[];
}

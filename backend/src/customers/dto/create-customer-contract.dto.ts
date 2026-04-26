import {
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
} from 'class-validator';
import {
  BillingUnit,
  CoreAllocationType,
} from '../../shared/types/domain.types';

export class CreateCustomerContractDto {
  @IsOptional()
  @IsString()
  contractNumber?: string;

  @IsDateString()
  startDate!: string;

  @IsDateString()
  endDate!: string;

  @IsOptional()
  @IsEnum(CoreAllocationType)
  coreType?: CoreAllocationType;

  @IsOptional()
  @IsInt()
  coreTotal?: number;

  @IsOptional()
  @IsString()
  sharedCoreRatio?: string | null;

  @IsOptional()
  @IsInt()
  billingEvery?: number;

  @IsOptional()
  @IsEnum(BillingUnit)
  billingUnit?: BillingUnit;
}

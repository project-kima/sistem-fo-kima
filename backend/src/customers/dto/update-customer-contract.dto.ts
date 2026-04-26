import {
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
} from 'class-validator';
import {
  BillingUnit,
  ContractStatus,
  CoreAllocationType,
} from '../../shared/types/domain.types';

export class UpdateCustomerContractDto {
  @IsOptional()
  @IsString()
  contractNumber?: string;

  @IsOptional()
  @IsDateString()
  startDate?: string;

  @IsOptional()
  @IsDateString()
  endDate?: string;

  @IsOptional()
  @IsEnum(ContractStatus)
  status?: ContractStatus;

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

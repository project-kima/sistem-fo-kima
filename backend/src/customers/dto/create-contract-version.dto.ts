import {
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
} from 'class-validator';
import { CoreAllocationType } from '../../shared/types/domain.types';

export class CreateContractVersionDto {
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
  bakDocumentId?: number | null;
}

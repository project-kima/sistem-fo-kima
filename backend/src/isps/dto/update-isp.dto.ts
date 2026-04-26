import {
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
} from 'class-validator';
import { IspPackageType, IspStatus } from '../../shared/types/domain.types';

export class UpdateIspDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsEnum(IspStatus)
  status?: IspStatus;

  @IsOptional()
  @IsString()
  contractReference?: string | null;

  @IsOptional()
  @IsDateString()
  contractStartDate?: string | null;

  @IsOptional()
  @IsDateString()
  contractPeriodStart?: string | null;

  @IsOptional()
  @IsDateString()
  contractPeriodEnd?: string | null;

  @IsOptional()
  @IsEnum(IspPackageType)
  paket?: IspPackageType;

  @IsOptional()
  @IsInt()
  jumlah?: number;
}

import {
  IsArray,
  IsDateString,
  IsEnum,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
} from 'class-validator';
import { CustomerStatus } from '../../shared/types/domain.types';

export class UpdateCustomerDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  ispName?: string;

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
}

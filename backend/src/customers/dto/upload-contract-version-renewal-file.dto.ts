import { Type } from 'class-transformer';
import { IsInt, IsOptional, Min } from 'class-validator';

export class UploadContractVersionRenewalFileDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  followUpId?: number;
}

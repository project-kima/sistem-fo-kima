import { IsInt, IsOptional, IsString, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class UploadRenewalFileDto {
  @IsOptional()
  @IsString()
  fileDataUrl?: string;

  @IsOptional()
  @IsString()
  fileName?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  followUpId?: number;
}

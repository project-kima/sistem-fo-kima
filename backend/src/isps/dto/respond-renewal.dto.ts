import { IsIn, IsOptional, IsString, IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class RespondRenewalDto {
  @IsIn(['lanjut', 'tidak'])
  decision!: 'lanjut' | 'tidak';

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

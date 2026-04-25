import { Type } from 'class-transformer';
import { IsIn, IsInt, IsOptional, Min } from 'class-validator';

export class RespondContractVersionRenewalDto {
  @IsIn(['lanjut', 'tidak'])
  decision!: 'lanjut' | 'tidak';

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  followUpId?: number;
}

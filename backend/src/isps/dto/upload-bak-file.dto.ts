import { IsOptional, IsString } from 'class-validator';

export class UploadBakFileDto {
  @IsOptional()
  @IsString()
  fileDataUrl?: string;

  @IsOptional()
  @IsString()
  fileName?: string;
}

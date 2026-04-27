import { IsString } from 'class-validator';

export class UploadIspLogoDto {
  @IsString()
  fileDataUrl!: string;
}

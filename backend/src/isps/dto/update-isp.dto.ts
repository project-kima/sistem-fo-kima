import { IspPackageType, IspStatus } from '../../shared/types/domain.types';

export class UpdateIspDto {
    name?: string;
    status?: IspStatus;
    contractReference?: string | null;
    contractStartDate?: string | null;
    contractPeriodStart?: string | null;
    contractPeriodEnd?: string | null;
    paket?: IspPackageType;
    jumlah?: number;
}

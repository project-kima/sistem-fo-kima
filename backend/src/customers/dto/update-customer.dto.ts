import { CustomerStatus } from '../../shared/types/domain.types';

export class UpdateCustomerDto {
    name?: string;
    ispName?: string;
    ispIds?: number[];
    newIspNames?: string[];
    status?: CustomerStatus;
    activationFeeAmount?: number;
    activationFeePaidAt?: string | null;
}

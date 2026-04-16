import { BillingUnit, CoreAllocationType } from '../../shared/types/domain.types';

export class CreateCustomerContractDto {
    contractNumber?: string;
    startDate!: string;
    endDate!: string;
    coreType?: CoreAllocationType;
    coreTotal?: number;
    sharedCoreRatio?: string | null;
    billingEvery?: number;
    billingUnit?: BillingUnit;
}

import {
  BillingUnit,
  ContractStatus,
  CoreAllocationType,
} from '../../shared/types/domain.types';

export class UpdateCustomerContractDto {
  contractNumber?: string;
  startDate?: string;
  endDate?: string;
  status?: ContractStatus;
  coreType?: CoreAllocationType;
  coreTotal?: number;
  sharedCoreRatio?: string | null;
  billingEvery?: number;
  billingUnit?: BillingUnit;
}

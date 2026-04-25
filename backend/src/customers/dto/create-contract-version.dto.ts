import { CoreAllocationType } from '../../shared/types/domain.types';

export class CreateContractVersionDto {
  startDate!: string;
  endDate!: string;
  coreType?: CoreAllocationType;
  coreTotal?: number;
  sharedCoreRatio?: string | null;
  bakDocumentId?: number | null;
}

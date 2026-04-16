import { Module } from '@nestjs/common';
import { InMemoryDataService } from './in-memory-data.service';

@Module({
  providers: [InMemoryDataService],
  exports: [InMemoryDataService],
})
export class StoreModule {}

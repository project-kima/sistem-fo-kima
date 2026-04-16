import { Module } from '@nestjs/common';
import { DocumentAutomationService } from './document-automation.service';
import { StoreModule } from '../store/store.module';

@Module({
  imports: [StoreModule],
  providers: [DocumentAutomationService],
  exports: [DocumentAutomationService],
})
export class AutomationModule {}

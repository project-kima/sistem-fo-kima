import { Module } from '@nestjs/common';
import { AutomationModule } from '../automation/automation.module';
import { StoreModule } from '../store/store.module';
import { DocumentsController } from './documents.controller';
import { DocumentsService } from './documents.service';

@Module({
  imports: [StoreModule, AutomationModule],
  controllers: [DocumentsController],
  providers: [DocumentsService],
  exports: [DocumentsService],
})
export class DocumentsModule { }

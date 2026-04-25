import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { DocumentsController } from './documents.controller';
import { DocumentsService } from './documents.service';
import { PrismaDocumentsService } from './prisma-documents.service';

@Module({
  imports: [PrismaModule],
  controllers: [DocumentsController],
  providers: [DocumentsService, PrismaDocumentsService],
  exports: [DocumentsService],
})
export class DocumentsModule {}

import { Injectable } from '@nestjs/common';
import { DocumentRecord } from '../shared/types/domain.types';
import { CreateDocumentDto } from './dto/create-document.dto';
import { PrismaDocumentsService } from './prisma-documents.service';

export interface CreateDocumentResponse {
  document: DocumentRecord;
  automation: Record<string, unknown>;
}

@Injectable()
export class DocumentsService {
  constructor(private readonly prismaDocuments: PrismaDocumentsService) {}

  async listByCustomer(
    customerId: number,
    rawJenisDokumen?: string,
  ): Promise<DocumentRecord[]> {
    return this.prismaDocuments.listByCustomer(customerId, rawJenisDokumen);
  }

  async getById(
    customerId: number,
    documentId: number,
  ): Promise<DocumentRecord> {
    return this.prismaDocuments.getById(customerId, documentId);
  }

  async create(
    customerId: number,
    payload: CreateDocumentDto,
    file?: Express.Multer.File,
  ): Promise<CreateDocumentResponse> {
    return this.prismaDocuments.create(customerId, payload, file);
  }

  async delete(
    customerId: number,
    documentId: number,
  ): Promise<{ deleted: boolean }> {
    return this.prismaDocuments.delete(customerId, documentId);
  }
}

import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
} from '@nestjs/common';
import { DocumentsService } from './documents.service';
import { CreateDocumentDto } from './dto/create-document.dto';

@Controller('api/customers/:customerId/documents')
export class DocumentsController {
  constructor(private readonly documentsService: DocumentsService) {}

  @Get()
  listByCustomer(
    @Param('customerId', ParseIntPipe) customerId: number,
    @Query('jenisDokumen') jenisDokumen?: string,
  ) {
    return this.documentsService.listByCustomer(customerId, jenisDokumen);
  }

  @Get(':documentId')
  getById(
    @Param('customerId', ParseIntPipe) customerId: number,
    @Param('documentId', ParseIntPipe) documentId: number,
  ) {
    return this.documentsService.getById(customerId, documentId);
  }

  @Post()
  create(
    @Param('customerId', ParseIntPipe) customerId: number,
    @Body() payload: CreateDocumentDto,
  ) {
    return this.documentsService.create(customerId, payload);
  }

  @Delete(':documentId')
  delete(
    @Param('customerId', ParseIntPipe) customerId: number,
    @Param('documentId', ParseIntPipe) documentId: number,
  ) {
    return this.documentsService.delete(customerId, documentId);
  }
}

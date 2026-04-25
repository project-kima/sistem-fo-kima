import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { IspsController } from './isps.controller';
import { IspsService } from './isps.service';
import { PrismaIspsService } from './prisma-isps.service';

@Module({
  imports: [PrismaModule],
  controllers: [IspsController],
  providers: [IspsService, PrismaIspsService],
  exports: [IspsService],
})
export class IspsModule {}

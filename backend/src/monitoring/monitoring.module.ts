import { Module } from '@nestjs/common';
import { MonitoringController } from './monitoring.controller';
import { MonitoringService } from './monitoring.service';
import { PrismaModule } from '../prisma/prisma.module';
import { PrismaMonitoringService } from './prisma-monitoring.service';

@Module({
  imports: [PrismaModule],
  controllers: [MonitoringController],
  providers: [MonitoringService, PrismaMonitoringService],
})
export class MonitoringModule {}

import { Injectable } from '@nestjs/common';
import { PrismaMonitoringService } from './prisma-monitoring.service';

@Injectable()
export class MonitoringService {
  constructor(private readonly prismaMonitoring: PrismaMonitoringService) {}

  async getBilling(query: { year?: string; isp?: string; status?: string }) {
    return this.prismaMonitoring.getBilling(query);
  }

  async getAlerts(query: { year?: string }) {
    return this.prismaMonitoring.getAlerts(query);
  }

  async getInsights(query: { year?: string }) {
    return this.prismaMonitoring.getInsights(query);
  }
}

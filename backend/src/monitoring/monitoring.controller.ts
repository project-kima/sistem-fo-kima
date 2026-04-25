import { Controller, Get, Query } from '@nestjs/common';
import { MonitoringService } from './monitoring.service';

@Controller('api/monitoring')
export class MonitoringController {
  constructor(private readonly monitoringService: MonitoringService) {}

  @Get('billing')
  getBilling(
    @Query('year') year?: string,
    @Query('isp') isp?: string,
    @Query('status') status?: string,
  ) {
    return this.monitoringService.getBilling({ year, isp, status });
  }

  @Get('alerts')
  getAlerts(@Query('year') year?: string) {
    return this.monitoringService.getAlerts({ year });
  }

  @Get('insights')
  getInsights(@Query('year') year?: string) {
    return this.monitoringService.getInsights({ year });
  }
}

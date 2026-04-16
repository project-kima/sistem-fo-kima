import { BadRequestException, Injectable } from '@nestjs/common';
import { InvoiceStatus } from '../shared/types/domain.types';
import { InMemoryDataService } from '../store/in-memory-data.service';

@Injectable()
export class MonitoringService {
  constructor(private readonly store: InMemoryDataService) { }

  getBilling(query: { year?: string; isp?: string; status?: string }) {
    const year = this.parseYear(query.year);
    const status = this.parseInvoiceStatus(query.status);

    const rows = this.store.getMonitoringBillingRows(year, {
      isp: query.isp,
      status,
    });

    const summary = this.buildSummary(rows);

    return {
      year,
      appliedFilters: {
        isp: query.isp ?? null,
        status: status ?? null,
      },
      summary,
      rows,
    };
  }

  getAlerts(query: { year?: string }) {
    const year = this.parseYear(query.year);

    return {
      year,
      alerts: this.store.getMonitoringAlerts(year),
    };
  }

  getInsights(query: { year?: string }) {
    const year = this.parseYear(query.year);
    return this.store.getMonitoringInsights(year);
  }

  private parseYear(value?: string): number {
    if (!value) {
      return new Date().getUTCFullYear();
    }

    const year = Number(value);
    if (!Number.isInteger(year) || year < 2000 || year > 2100) {
      throw new BadRequestException('year must be a number between 2000 and 2100.');
    }

    return year;
  }

  private parseInvoiceStatus(value?: string): InvoiceStatus | undefined {
    if (!value) {
      return undefined;
    }

    const validStatuses = Object.values(InvoiceStatus);
    if (!validStatuses.includes(value as InvoiceStatus)) {
      throw new BadRequestException(
        `status must be one of: ${validStatuses.join(', ')}`,
      );
    }

    return value as InvoiceStatus;
  }

  private buildSummary(
    rows: Array<{
      months: InvoiceStatus[];
    }>,
  ) {
    const summary = {
      lunas: 0,
      belum_bayar: 0,
      terlambat: 0,
      belum_ditagih: 0,
    };

    rows.forEach((row) => {
      row.months.forEach((status) => {
        summary[status] += 1;
      });
    });

    return summary;
  }
}

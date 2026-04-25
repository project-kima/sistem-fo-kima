import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '@prisma/client';
import { getRuntimeConfig } from '../config/runtime-env';

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  constructor() {
    const { databaseUrl } = getRuntimeConfig();

    super({
      adapter: new PrismaPg({ connectionString: databaseUrl }),
    });
  }

  isEnabled(): boolean {
    return true;
  }

  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}

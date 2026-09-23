import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(PrismaService.name);

  async onModuleInit() {
    try {
      await this.$connect();
      this.logger.log('Database connected (PostgreSQL)');
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Unknown database error';

      this.logger.error(
        [
          'PostgreSQL connection failed.',
          'Local setup (no Docker):',
          '1) Install PostgreSQL',
          '2) Create database: job_portal',
          '3) Set DATABASE_URL in .env',
          '4) Run: pnpm exec prisma migrate deploy && pnpm run db:seed',
          `Error: ${message}`,
        ].join(' '),
      );
      throw error;
    }
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}

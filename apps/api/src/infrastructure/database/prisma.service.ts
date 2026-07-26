import {
  Injectable,
  Logger,
  OnApplicationShutdown,
  OnModuleInit,
} from '@nestjs/common';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../../generated/prisma/client';

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnApplicationShutdown
{
  private readonly logger = new Logger(PrismaService.name);

  constructor() {
    const databaseUrl = process.env.DATABASE_URL;

    if (!databaseUrl) {
      throw new Error(
        'DATABASE_URL no está configurada. La API no puede iniciar.',
      );
    }

    const adapter = new PrismaPg({
      connectionString: databaseUrl,
    });

    super({
      adapter,
    });
  }

  async onModuleInit(): Promise<void> {
    try {
      await this.$connect();
      await this.$queryRaw`SELECT 1`;

      this.logger.log('Conexión con PostgreSQL establecida');
    } catch (error: unknown) {
      this.logger.error(
        'No fue posible conectar con PostgreSQL',
        error instanceof Error ? error.stack : undefined,
      );

      throw new Error('No fue posible establecer la conexión con PostgreSQL.');
    }
  }

  async onApplicationShutdown(): Promise<void> {
    try {
      await this.$disconnect();

      this.logger.log('Conexión con PostgreSQL cerrada');
    } catch {
      this.logger.error('Se produjo un error al cerrar PostgreSQL');
    }
  }

  async isHealthy(): Promise<boolean> {
    try {
      await this.$queryRaw`SELECT 1`;
      return true;
    } catch {
      return false;
    }
  }
}

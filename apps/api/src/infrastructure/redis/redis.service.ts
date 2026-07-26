import {
  Inject,
  Injectable,
  Logger,
  OnApplicationShutdown,
  OnModuleInit,
} from '@nestjs/common';
import type Redis from 'ioredis';
import { REDIS_CLIENT } from './redis.constants';

@Injectable()
export class RedisService implements OnModuleInit, OnApplicationShutdown {
  private readonly logger = new Logger(RedisService.name);

  constructor(
    @Inject(REDIS_CLIENT)
    private readonly client: Redis,
  ) {}

  async onModuleInit(): Promise<void> {
    try {
      const result = await this.client.ping();

      if (result !== 'PONG') {
        throw new Error('Redis no respondió con PONG');
      }

      this.logger.log('Conexión con Redis establecida');
    } catch {
      this.logger.error('No fue posible conectar con Redis');

      throw new Error('No fue posible establecer la conexión con Redis.');
    }
  }

  async onApplicationShutdown(): Promise<void> {
    try {
      await this.client.quit();
      this.logger.log('Conexión con Redis cerrada');
    } catch {
      this.client.disconnect();
      this.logger.error('Redis tuvo que desconectarse de forma forzada');
    }
  }

  async isHealthy(): Promise<boolean> {
    try {
      return (await this.client.ping()) === 'PONG';
    } catch {
      return false;
    }
  }

  getClient(): Redis {
    return this.client;
  }
}

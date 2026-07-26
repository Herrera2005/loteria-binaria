import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { RedisService } from '../../infrastructure/redis/redis.service';

@Injectable()
export class HealthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  getApiHealth() {
    return {
      status: 'ok',
      service: 'loteria-binaria-api',
      timestamp: new Date().toISOString(),
      uptimeSeconds: Math.floor(process.uptime()),
    };
  }

  async getDatabaseHealth() {
    const healthy = await this.prisma.isHealthy();

    return {
      service: 'postgresql',
      status: healthy ? 'up' : 'down',
      timestamp: new Date().toISOString(),
    };
  }

  async getRedisHealth() {
    const healthy = await this.redis.isHealthy();

    return {
      service: 'redis',
      status: healthy ? 'up' : 'down',
      timestamp: new Date().toISOString(),
    };
  }
}

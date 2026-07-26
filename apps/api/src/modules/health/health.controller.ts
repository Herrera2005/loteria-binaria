import { Controller, Get, HttpStatus } from '@nestjs/common';
import { AppError } from '../../common/errors/app-error';
import { ERROR_CODES } from '../../common/errors/error-codes';
import { HealthService } from './health.service';

@Controller('health')
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get()
  getHealth() {
    return this.healthService.getApiHealth();
  }

  @Get('database')
  async getDatabaseHealth() {
    const result = await this.healthService.getDatabaseHealth();

    if (result.status !== 'up') {
      throw new AppError({
        statusCode: HttpStatus.SERVICE_UNAVAILABLE,
        code: ERROR_CODES.DATABASE_UNAVAILABLE,
        message: 'PostgreSQL no está disponible.',
      });
    }

    return result;
  }

  @Get('redis')
  async getRedisHealth() {
    const result = await this.healthService.getRedisHealth();

    if (result.status !== 'up') {
      throw new AppError({
        statusCode: HttpStatus.SERVICE_UNAVAILABLE,
        code: ERROR_CODES.REDIS_UNAVAILABLE,
        message: 'Redis no está disponible.',
      });
    }

    return result;
  }
}

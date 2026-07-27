import {
  Module
} from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { CorrelationIdMiddleware } from './common/middleware/correlation-id.middleware';
import { RequestContextService } from './common/context/request-context.service';

import appConfig from './config/app.config';
import databaseConfig from './config/database.config';
import { envValidationSchema } from './config/env.validation';
import redisConfig from './config/redis.config';

import { PrismaModule } from './infrastructure/database/prisma.module';
import { RedisModule } from './infrastructure/redis/redis.module';
import { HealthModule } from './modules/health/health.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      cache: true,

      envFilePath: ['../../.env', '.env'],

      load: [appConfig, databaseConfig, redisConfig],

      validationSchema: envValidationSchema,

      validationOptions: {
        abortEarly: false,
        allowUnknown: true,
      },
    }),

    PrismaModule,
    RedisModule,
    HealthModule,
  ],

  providers: [RequestContextService, CorrelationIdMiddleware],
})

export class AppModule {}
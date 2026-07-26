import { Logger, ValidationPipe, VersioningType } from '@nestjs/common';
import type { CorsOptions } from '@nestjs/common/interfaces/external/cors-options.interface';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';

import { AppModule } from './app.module';
import { GlobalExceptionFilter } from './common/filters/global-exception.filter';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule, {
    bufferLogs: true,
  });

  const configService = app.get(ConfigService);

  const logger = new Logger('Bootstrap');

  const port = configService.getOrThrow<number>('API_PORT');

  const allowedOrigins = configService
    .getOrThrow<string>('CORS_ALLOWED_ORIGINS')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);

  app.enableShutdownHooks();

  app.setGlobalPrefix('api');

  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
  });

  const corsOptions: CorsOptions = {
    origin: (origin, callback) => {
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
        return;
      }

      callback(new Error('Origen no permitido por CORS'), false);
    },

    credentials: true,

    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],

    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'X-Correlation-Id',
      'Idempotency-Key',
    ],

    exposedHeaders: ['X-Correlation-Id'],
  };

  app.enableCors(corsOptions);

  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
      forbidNonWhitelisted: true,
      forbidUnknownValues: true,
      validationError: {
        target: false,
        value: false,
      },
    }),
  );

  app.useGlobalFilters(new GlobalExceptionFilter());

  await app.listen(port, '0.0.0.0');

  logger.log(`API iniciada en http://localhost:${port}/api/v1`);
}

void bootstrap();

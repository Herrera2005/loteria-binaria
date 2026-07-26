import { Global, Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';
import { REDIS_CLIENT } from './redis.constants';
import { RedisService } from './redis.service';

@Global()
@Module({
  providers: [
    {
      provide: REDIS_CLIENT,
      inject: [ConfigService],
      useFactory: (configService: ConfigService): Redis => {
        const redisUrl = configService.getOrThrow<string>('REDIS_URL');

        return new Redis(redisUrl, {
          enableOfflineQueue: false,
          maxRetriesPerRequest: 1,
          connectTimeout: 5_000,
          retryStrategy: (attempt) => Math.min(attempt * 500, 3_000),
        });
      },
    },
    RedisService,
  ],
  exports: [REDIS_CLIENT, RedisService],
})
export class RedisModule {}

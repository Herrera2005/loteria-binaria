import { Injectable, NestMiddleware } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import type { NextFunction, Response } from 'express';
import { RequestContextService } from '../context/request-context.service';
import type { RequestWithCorrelationId } from '../types/request-with-correlation-id';

const CORRELATION_HEADER = 'x-correlation-id';

@Injectable()
export class CorrelationIdMiddleware implements NestMiddleware {
  constructor(private readonly requestContext: RequestContextService) {}

  use(
    request: RequestWithCorrelationId,
    response: Response,
    next: NextFunction,
  ): void {
    const headerValue = request.headers[CORRELATION_HEADER];

    const receivedId = Array.isArray(headerValue)
      ? headerValue[0]
      : headerValue;

    const correlationId = this.isValidCorrelationId(receivedId)
      ? receivedId
      : randomUUID();

    request.correlationId = correlationId;

    response.setHeader('X-Correlation-Id', correlationId);

    this.requestContext.run({ correlationId }, next);
  }

  private isValidCorrelationId(value: string | undefined): value is string {
    return typeof value === 'string' && /^[a-zA-Z0-9._:-]{8,128}$/.test(value);
  }
}

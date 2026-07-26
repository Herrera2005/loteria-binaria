import { HttpException, HttpStatus } from '@nestjs/common';
import type { ErrorCode } from './error-codes';

export interface AppErrorOptions {
  statusCode: HttpStatus;
  code: ErrorCode;
  message: string;
  details?: unknown;
}

export class AppError extends HttpException {
  readonly code: ErrorCode;
  readonly details: unknown;

  constructor(options: AppErrorOptions) {
    super(options.message, options.statusCode);

    this.code = options.code;
    this.details = options.details ?? null;
  }
}

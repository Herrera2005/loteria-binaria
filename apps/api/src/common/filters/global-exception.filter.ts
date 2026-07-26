import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { AppError } from '../errors/app-error';
import { ERROR_CODES } from '../errors/error-codes';
import type { RequestWithCorrelationId } from '../types/request-with-correlation-id';

interface NormalizedError {
  statusCode: HttpStatus;
  code: string;
  message: string;
  details: unknown;
}

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(GlobalExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const httpContext = host.switchToHttp();

    const request = httpContext.getRequest<
      RequestWithCorrelationId & Request
    >();

    const response = httpContext.getResponse<Response>();

    const error = this.normalizeException(exception);

    const correlationId = request.correlationId ?? 'correlation-id-unavailable';

    const responseBody = {
      statusCode: error.statusCode,
      code: error.code,
      message: error.message,
      correlationId,
      details: error.details,
    };

    const logData = JSON.stringify({
      correlationId,
      statusCode: error.statusCode,
      code: error.code,
      method: request.method,
      path: request.originalUrl ?? request.url,
    });

    if (error.statusCode >= HttpStatus.INTERNAL_SERVER_ERROR) {
      this.logger.error(
        logData,
        exception instanceof Error ? exception.stack : undefined,
      );
    } else {
      this.logger.warn(logData);
    }

    response.status(error.statusCode).json(responseBody);
  }

  private normalizeException(exception: unknown): NormalizedError {
    if (exception instanceof AppError) {
      return {
        statusCode: exception.getStatus(),
        code: exception.code,
        message: exception.message,
        details: exception.details,
      };
    }

    if (exception instanceof HttpException) {
      const statusCode = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      const responseObject =
        typeof exceptionResponse === 'object' && exceptionResponse !== null
          ? (exceptionResponse as Record<string, unknown>)
          : null;

      const rawMessage = responseObject?.message;

      return {
        statusCode,
        code: this.mapStatusCode(statusCode),
        message: this.getPublicMessage(statusCode),
        details: Array.isArray(rawMessage) ? rawMessage : null,
      };
    }

    return {
      statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
      code: ERROR_CODES.INTERNAL_SERVER_ERROR,
      message: 'Se produjo un error interno.',
      details: null,
    };
  }

  private mapStatusCode(statusCode: HttpStatus): string {
    switch (statusCode) {
      case HttpStatus.BAD_REQUEST:
        return ERROR_CODES.VALIDATION_ERROR;
      case HttpStatus.UNAUTHORIZED:
        return ERROR_CODES.UNAUTHORIZED;
      case HttpStatus.FORBIDDEN:
        return ERROR_CODES.FORBIDDEN;
      case HttpStatus.NOT_FOUND:
        return ERROR_CODES.RESOURCE_NOT_FOUND;
      case HttpStatus.CONFLICT:
        return ERROR_CODES.CONFLICT;
      case HttpStatus.SERVICE_UNAVAILABLE:
        return ERROR_CODES.SERVICE_UNAVAILABLE;
      default:
        return statusCode >= HttpStatus.INTERNAL_SERVER_ERROR
          ? ERROR_CODES.INTERNAL_SERVER_ERROR
          : `HTTP_${statusCode}`;
    }
  }

  private getPublicMessage(statusCode: HttpStatus): string {
    switch (statusCode) {
      case HttpStatus.BAD_REQUEST:
        return 'La solicitud contiene datos inválidos.';
      case HttpStatus.UNAUTHORIZED:
        return 'Se requiere autenticación.';
      case HttpStatus.FORBIDDEN:
        return 'No tiene permisos para realizar esta operación.';
      case HttpStatus.NOT_FOUND:
        return 'El recurso solicitado no existe.';
      case HttpStatus.CONFLICT:
        return 'La operación entra en conflicto con el estado actual.';
      case HttpStatus.SERVICE_UNAVAILABLE:
        return 'El servicio no está disponible temporalmente.';
      default:
        return statusCode >= HttpStatus.INTERNAL_SERVER_ERROR
          ? 'Se produjo un error interno.'
          : 'La solicitud no pudo completarse.';
    }
  }
}

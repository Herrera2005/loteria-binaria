import { Injectable } from '@nestjs/common';
import { AsyncLocalStorage } from 'node:async_hooks';

export interface RequestContext {
  correlationId: string;
}

@Injectable()
export class RequestContextService {
  private readonly storage = new AsyncLocalStorage<RequestContext>();

  run<T>(context: RequestContext, callback: () => T): T {
    return this.storage.run(context, callback);
  }

  getCorrelationId(): string | undefined {
    return this.storage.getStore()?.correlationId;
  }

  requireCorrelationId(): string {
    const correlationId = this.getCorrelationId();

    if (!correlationId) {
      throw new Error('No existe correlationId en el contexto actual');
    }

    return correlationId;
  }
}

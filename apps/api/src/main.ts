import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule);

  const port = Number(process.env.API_PORT ?? process.env.PORT ?? 3001);

  await app.listen(port, '0.0.0.0');

  console.log(`API ejecutándose en http://localhost:${port}`);
}

void bootstrap();

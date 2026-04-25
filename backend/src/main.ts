import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { getRuntimeConfig } from './config/runtime-env';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const { host, port } = getRuntimeConfig();
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  app.enableCors(); // Enable CORS for frontend
  app.enableShutdownHooks();

  await app.listen(port, host);

  console.log(`Backend ready at http://${host}:${port}`);
}
void bootstrap();

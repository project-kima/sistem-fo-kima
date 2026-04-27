import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { getRuntimeConfig } from './config/runtime-env';
import { ValidationPipe } from '@nestjs/common';
import * as express from 'express';

async function bootstrap() {
  const { host, port } = getRuntimeConfig();
  const app = await NestFactory.create(AppModule);

  // Increase the limit for base64 uploads
  app.use(express.json({ limit: '50mb' }));
  app.use(express.urlencoded({ limit: '50mb', extended: true }));

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

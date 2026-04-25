const parsePort = (rawPort: string | undefined): number => {
  const port = Number(rawPort ?? '4000');

  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error(
      `PORT must be an integer between 1 and 65535. Received: ${rawPort ?? 'undefined'}`,
    );
  }

  return port;
};

export const getRuntimeConfig = () => {
  const databaseUrl = process.env.DATABASE_URL?.trim();

  if (!databaseUrl) {
    throw new Error('DATABASE_URL is required.');
  }

  return {
    databaseUrl,
    host: process.env.HOST?.trim() || '127.0.0.1',
    port: parsePort(process.env.PORT),
  };
};

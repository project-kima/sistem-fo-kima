import { randomBytes, scryptSync, timingSafeEqual } from 'crypto';

const SALT_BYTES = 16;
const KEY_LENGTH = 64;

export function hashPassword(password: string) {
  const salt = randomBytes(SALT_BYTES).toString('hex');
  const derivedKey = scryptSync(password, salt, KEY_LENGTH).toString('hex');
  return `${salt}:${derivedKey}`;
}

export function verifyPassword(password: string, passwordHash: string) {
  const [salt, storedKey] = String(passwordHash ?? '').split(':');

  if (!salt || !storedKey) {
    return false;
  }

  const incomingKey = scryptSync(password, salt, KEY_LENGTH);
  const storedKeyBuffer = Buffer.from(storedKey, 'hex');

  if (incomingKey.length !== storedKeyBuffer.length) {
    return false;
  }

  return timingSafeEqual(incomingKey, storedKeyBuffer);
}

import { randomInt } from 'crypto';
import { OTP_LENGTH } from '../constants/app.constants';

export function generateOtp(): string {
  const min = 10 ** (OTP_LENGTH - 1);
  const max = 10 ** OTP_LENGTH - 1;
  return String(randomInt(min, max + 1));
}

export function generateSecureToken(): string {
  return crypto.randomUUID().replace(/-/g, '');
}

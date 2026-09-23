import { JwtSignOptions } from '@nestjs/jwt';

export function jwtExpiresIn(
  value: string | undefined,
  fallback: string,
): JwtSignOptions['expiresIn'] {
  return (value ?? fallback) as JwtSignOptions['expiresIn'];
}

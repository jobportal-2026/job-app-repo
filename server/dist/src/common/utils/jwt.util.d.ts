import { JwtSignOptions } from '@nestjs/jwt';
export declare function jwtExpiresIn(value: string | undefined, fallback: string): JwtSignOptions['expiresIn'];

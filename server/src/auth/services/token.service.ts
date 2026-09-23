import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { randomUUID } from 'crypto';
import { AppRole } from '../../common/constants/roles.enum';
import {
  AdminJwtPayload,
  AdminRefreshJwtPayload,
  JwtPayload,
  RefreshJwtPayload,
} from '../../common/interfaces/jwt-payload.interface';
import { hashValue } from '../../common/utils/hash.util';
import { jwtExpiresIn } from '../../common/utils/jwt.util';
import { RefreshTokenRepository } from '../repositories/refresh-token.repository';

@Injectable()
export class TokenService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly refreshTokenRepository: RefreshTokenRepository,
  ) {}

  async issueUserTokens(params: {
    userId: string;
    phone: string;
    email?: string | null;
    role: AppRole;
    userAgent?: string;
    ipAddress?: string;
  }) {
    const jti = randomUUID();
    const accessToken = await this.jwtService.signAsync(
      {
        sub: params.userId,
        phone: params.phone,
        email: params.email,
        role: params.role,
        jti,
        type: 'access',
      } satisfies JwtPayload,
      {
        secret: this.configService.get<string>('JWT_SECRET'),
        expiresIn: jwtExpiresIn(
          this.configService.get<string>('JWT_ACCESS_EXPIRES_IN'),
          '15m',
        ),
      },
    );

    const refreshJti = randomUUID();
    const refreshToken = await this.jwtService.signAsync(
      {
        sub: params.userId,
        jti: refreshJti,
        type: 'refresh',
      } satisfies RefreshJwtPayload,
      {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
        expiresIn: jwtExpiresIn(
          this.configService.get<string>('JWT_REFRESH_EXPIRES_IN'),
          '7d',
        ),
      },
    );

    const refreshExpiresIn =
      this.configService.get<string>('JWT_REFRESH_EXPIRES_IN') ?? '7d';
    const expiresAt = this.calculateExpiry(refreshExpiresIn);

    await this.refreshTokenRepository.create({
      tokenHash: await hashValue(refreshToken),
      user: { connect: { id: params.userId } },
      userAgent: params.userAgent,
      ipAddress: params.ipAddress,
      expiresAt,
    });

    return { accessToken, refreshToken };
  }

  async issueAdminTokens(params: {
    adminId: string;
    email: string;
    permissions: string[];
    userAgent?: string;
    ipAddress?: string;
  }) {
    const jti = randomUUID();
    const accessToken = await this.jwtService.signAsync(
      {
        sub: params.adminId,
        email: params.email,
        permissions: params.permissions,
        jti,
        type: 'admin_access',
      } satisfies AdminJwtPayload,
      {
        secret: this.configService.get<string>('ADMIN_JWT_SECRET'),
        expiresIn: jwtExpiresIn(
          this.configService.get<string>('JWT_ACCESS_EXPIRES_IN'),
          '15m',
        ),
      },
    );

    const refreshJti = randomUUID();
    const refreshToken = await this.jwtService.signAsync(
      {
        sub: params.adminId,
        jti: refreshJti,
        type: 'admin_refresh',
      } satisfies AdminRefreshJwtPayload,
      {
        secret: this.configService.get<string>('ADMIN_JWT_REFRESH_SECRET'),
        expiresIn: jwtExpiresIn(
          this.configService.get<string>('JWT_REFRESH_EXPIRES_IN'),
          '7d',
        ),
      },
    );

    return { accessToken, refreshToken, refreshJti };
  }

  private calculateExpiry(duration: string): Date {
    const match = duration.match(/^(\d+)([smhd])$/);
    if (!match) {
      return new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
    }

    const value = Number(match[1]);
    const unit = match[2];
    const multipliers: Record<string, number> = {
      s: 1000,
      m: 60 * 1000,
      h: 60 * 60 * 1000,
      d: 24 * 60 * 60 * 1000,
    };

    return new Date(Date.now() + value * multipliers[unit]);
  }
}

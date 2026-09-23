import { HttpStatus, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { AuditAction } from '@prisma/client';
import { BusinessException } from '../../common/exceptions/business.exception';
import {
  AdminJwtPayload,
  AdminRefreshJwtPayload,
} from '../../common/interfaces/jwt-payload.interface';
import { hashValue, verifyHash } from '../../common/utils/hash.util';
import { jwtExpiresIn } from '../../common/utils/jwt.util';
import { AuditService } from '../../shared/audit/audit.service';
import { AdminLoginDto } from './dto/admin-login.dto';
import { AdminRepository } from './repositories/admin.repository';

@Injectable()
export class AdminAuthService {
  constructor(
    private readonly adminRepository: AdminRepository,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly auditService: AuditService,
  ) {}

  async login(dto: AdminLoginDto, userAgent?: string, ipAddress?: string) {
    const admin = await this.adminRepository.findByEmail(dto.email);
    if (!admin || !admin.isActive) {
      throw new BusinessException('Invalid credentials', HttpStatus.UNAUTHORIZED);
    }

    const valid = await verifyHash(admin.passwordHash, dto.password);
    if (!valid) {
      throw new BusinessException('Invalid credentials', HttpStatus.UNAUTHORIZED);
    }

    await this.adminRepository.updateLastLogin(admin.id);

    await this.auditService.log({
      action: AuditAction.LOGIN,
      entityType: 'Admin',
      entityId: admin.id,
      adminId: admin.id,
      ipAddress,
      userAgent,
    });

    return this.issueTokens(admin, userAgent, ipAddress);
  }

  async refresh(refreshToken: string, userAgent?: string, ipAddress?: string) {
    let payload: AdminRefreshJwtPayload;

    try {
      payload = await this.jwtService.verifyAsync<AdminRefreshJwtPayload>(
        refreshToken,
        {
          secret: this.configService.get<string>('ADMIN_JWT_REFRESH_SECRET'),
        },
      );
    } catch {
      throw new BusinessException('Invalid refresh token', HttpStatus.UNAUTHORIZED);
    }

    const tokens = await this.adminRepository.findActiveRefreshTokens(payload.sub);
    let matchedId: string | null = null;

    for (const stored of tokens) {
      const valid = await verifyHash(stored.tokenHash, refreshToken);
      if (valid) {
        matchedId = stored.id;
        break;
      }
    }

    if (!matchedId) {
      throw new BusinessException('Invalid refresh token', HttpStatus.UNAUTHORIZED);
    }

    await this.adminRepository.revokeRefreshToken(matchedId);

    const admin = await this.adminRepository.findById(payload.sub);
    if (!admin || !admin.isActive) {
      throw new BusinessException('Admin not found', HttpStatus.NOT_FOUND);
    }

    return this.issueTokens(admin, userAgent, ipAddress);
  }

  private async issueTokens(
    admin: {
      id: string;
      email: string;
      name: string;
      permissions: string[];
    },
    userAgent?: string,
    ipAddress?: string,
  ) {
    const jti = crypto.randomUUID();
    const accessToken = await this.jwtService.signAsync(
      {
        sub: admin.id,
        email: admin.email,
        permissions: admin.permissions,
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

    const refreshToken = await this.jwtService.signAsync(
      {
        sub: admin.id,
        jti: crypto.randomUUID(),
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

    await this.adminRepository.createRefreshToken({
      tokenHash: await hashValue(refreshToken),
      admin: { connect: { id: admin.id } },
      userAgent,
      ipAddress,
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
    });

    return {
      accessToken,
      refreshToken,
      admin: {
        id: admin.id,
        email: admin.email,
        name: admin.name,
        permissions: admin.permissions,
      },
    };
  }

  async logout(adminId: string, refreshToken?: string) {
    if (refreshToken) {
      const tokens = await this.adminRepository.findActiveRefreshTokens(adminId);
      for (const stored of tokens) {
        const valid = await verifyHash(stored.tokenHash, refreshToken);
        if (valid) {
          await this.adminRepository.revokeRefreshToken(stored.id);
          break;
        }
      }
    } else {
      await this.adminRepository.revokeAllRefreshTokens(adminId);
    }

    await this.auditService.log({
      action: AuditAction.LOGOUT,
      entityType: 'Admin',
      entityId: adminId,
      adminId,
    });

    return { message: 'Logged out successfully' };
  }

  async me(adminId: string) {
    const admin = await this.adminRepository.findById(adminId);
    if (!admin || !admin.isActive) {
      throw new BusinessException('Admin not found', HttpStatus.NOT_FOUND);
    }

    return {
      id: admin.id,
      email: admin.email,
      name: admin.name,
      permissions: admin.permissions,
    };
  }
}

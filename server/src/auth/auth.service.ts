import { HttpStatus, Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { AuditAction, User, UserRole, UserStatus } from '@prisma/client';
import { AppRole } from '../common/constants/roles.enum';
import { BusinessException } from '../common/exceptions/business.exception';
import { RefreshJwtPayload } from '../common/interfaces/jwt-payload.interface';
import { hashValue, verifyHash } from '../common/utils/hash.util';
import { sanitizeText } from '../common/utils/sanitize.util';
import { AuditService } from '../shared/audit/audit.service';
import { PrismaService } from '../database/prisma.service';
import { ChangePasswordDto } from './dto/change-password.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { RefreshTokenRepository } from './repositories/refresh-token.repository';
import { RevokedTokenRepository } from './repositories/revoked-token.repository';
import { UsersRepository } from './repositories/users.repository';
import { OtpService } from './services/otp.service';
import { TokenService } from './services/token.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersRepository: UsersRepository,
    private readonly refreshTokenRepository: RefreshTokenRepository,
    private readonly revokedTokenRepository: RevokedTokenRepository,
    private readonly otpService: OtpService,
    private readonly tokenService: TokenService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly auditService: AuditService,
    private readonly prisma: PrismaService,
  ) {}

  async register(dto: RegisterDto) {
    const phone = dto.phone;
    const existingPhone = await this.usersRepository.findByPhone(phone);
    if (existingPhone) {
      throw new BusinessException('Phone already registered', HttpStatus.CONFLICT);
    }

    if (dto.email) {
      const existingEmail = await this.usersRepository.findByEmail(dto.email);
      if (existingEmail) {
        throw new BusinessException('Email already registered', HttpStatus.CONFLICT);
      }
    }

    const passwordHash = await hashValue(dto.password);
    const role = this.mapRole(dto.role);

    const user = await this.usersRepository.create({
      name: sanitizeText(dto.name),
      email: dto.email,
      phone,
      passwordHash,
      role,
      status: UserStatus.PENDING_PHONE_VERIFICATION,
    });

    await this.usersRepository.createProfileForRole(user);
    await this.otpService.sendRegistrationOtp(phone);

    await this.auditService.log({
      action: AuditAction.CREATE,
      entityType: 'User',
      entityId: user.id,
      userId: user.id,
      metadata: { event: 'register' },
    });

    return {
      message: 'Registration successful. Verify phone with OTP.',
      userId: user.id,
      phone: user.phone,
    };
  }

  async verifyPhone(phone: string, code: string) {
    const user = await this.usersRepository.findByPhone(phone);
    if (!user) {
      throw new BusinessException('User not found', HttpStatus.NOT_FOUND);
    }

    await this.otpService.verifyRegistrationOtp(phone, code);

    const updated = await this.usersRepository.update(user.id, {
      phoneVerified: true,
      phoneVerifiedAt: new Date(),
      status: UserStatus.ACTIVE,
    });

    await this.auditService.log({
      action: AuditAction.PHONE_VERIFY,
      entityType: 'User',
      entityId: user.id,
      userId: user.id,
    });

    return this.mapUser(updated);
  }

  async resendOtp(phone: string) {
    const user = await this.usersRepository.findByPhone(phone);
    if (!user) {
      throw new BusinessException('User not found', HttpStatus.NOT_FOUND);
    }

    if (user.phoneVerified) {
      throw new BusinessException('Phone already verified', HttpStatus.BAD_REQUEST);
    }

    await this.otpService.sendRegistrationOtp(phone);
    return { message: 'OTP sent' };
  }

  async login(dto: LoginDto, userAgent?: string, ipAddress?: string) {
    const user = await this.usersRepository.findByEmail(dto.email);
    if (!user || !user.passwordHash) {
      throw new BusinessException('Invalid credentials', HttpStatus.UNAUTHORIZED);
    }

    const validPassword = await verifyHash(user.passwordHash, dto.password);
    if (!validPassword) {
      throw new BusinessException('Invalid credentials', HttpStatus.UNAUTHORIZED);
    }

    this.assertActiveUser(user, dto.role);

    const tokens = await this.tokenService.issueUserTokens({
      userId: user.id,
      phone: user.phone,
      email: user.email,
      role: dto.role,
      userAgent,
      ipAddress,
    });

    await this.usersRepository.update(user.id, { lastLoginAt: new Date() });

    await this.auditService.log({
      action: AuditAction.LOGIN,
      entityType: 'User',
      entityId: user.id,
      userId: user.id,
      ipAddress,
      userAgent,
    });

    return {
      ...tokens,
      user: this.mapUser(user),
    };
  }

  async refresh(refreshToken: string, userAgent?: string, ipAddress?: string) {
    let payload: RefreshJwtPayload;

    try {
      payload = await this.jwtService.verifyAsync<RefreshJwtPayload>(
        refreshToken,
        { secret: this.configService.get<string>('JWT_REFRESH_SECRET') },
      );
    } catch {
      throw new BusinessException('Invalid refresh token', HttpStatus.UNAUTHORIZED);
    }

    if (payload.type !== 'refresh') {
      throw new BusinessException('Invalid refresh token', HttpStatus.UNAUTHORIZED);
    }

    const tokens = await this.refreshTokenRepository.findActiveByUserId(
      payload.sub,
    );

    let matchedTokenId: string | null = null;
    for (const stored of tokens) {
      const valid = await verifyHash(stored.tokenHash, refreshToken);
      if (valid) {
        matchedTokenId = stored.id;
        break;
      }
    }

    if (!matchedTokenId) {
      throw new BusinessException('Invalid refresh token', HttpStatus.UNAUTHORIZED);
    }

    await this.refreshTokenRepository.revoke(matchedTokenId);

    const user = await this.usersRepository.findById(payload.sub);
    if (!user) {
      throw new BusinessException('User not found', HttpStatus.NOT_FOUND);
    }

    const role = this.reverseMapRole(user.role);
    const newTokens = await this.tokenService.issueUserTokens({
      userId: user.id,
      phone: user.phone,
      email: user.email,
      role,
      userAgent,
      ipAddress,
    });

    return {
      ...newTokens,
      user: this.mapUser(user),
    };
  }

  async logout(
    userId: string,
    accessJti: string,
    accessExp?: number,
    refreshToken?: string,
  ) {
    if (accessJti) {
      const expiresAt = accessExp
        ? new Date(accessExp * 1000)
        : new Date(Date.now() + 15 * 60 * 1000);
      await this.revokedTokenRepository.revoke(accessJti, expiresAt);
    }

    if (refreshToken) {
      const tokens = await this.refreshTokenRepository.findActiveByUserId(userId);
      for (const stored of tokens) {
        const valid = await verifyHash(stored.tokenHash, refreshToken);
        if (valid) {
          await this.refreshTokenRepository.revoke(stored.id);
          break;
        }
      }
    } else {
      await this.refreshTokenRepository.revokeAllForUser(userId);
    }

    await this.auditService.log({
      action: AuditAction.LOGOUT,
      entityType: 'User',
      entityId: userId,
      userId,
    });

    return { message: 'Logged out successfully' };
  }

  async getCurrentUser(userId: string) {
    const user = await this.usersRepository.findById(userId);
    if (!user) {
      throw new BusinessException('User not found', HttpStatus.NOT_FOUND);
    }
    return this.mapUser(user);
  }

  async changePassword(userId: string, dto: ChangePasswordDto) {
    const user = await this.usersRepository.findById(userId);
    if (!user || !user.passwordHash) {
      throw new BusinessException('User not found', HttpStatus.NOT_FOUND);
    }

    const valid = await verifyHash(user.passwordHash, dto.currentPassword);
    if (!valid) {
      throw new BusinessException('Current password is incorrect', HttpStatus.BAD_REQUEST);
    }

    const passwordHash = await hashValue(dto.newPassword);
    await this.usersRepository.update(userId, { passwordHash });
    await this.refreshTokenRepository.revokeAllForUser(userId);

    await this.auditService.log({
      action: AuditAction.PASSWORD_CHANGE,
      entityType: 'User',
      entityId: userId,
      userId,
    });

    return { message: 'Password changed successfully' };
  }

  async forgotPassword(dto: ForgotPasswordDto) {
    const user = await this.usersRepository.findByPhone(dto.phone);
    if (!user) {
      return { message: 'If the phone exists, an OTP has been sent' };
    }

    await this.otpService.sendPasswordResetOtp(dto.phone);
    return { message: 'If the phone exists, an OTP has been sent' };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const user = await this.usersRepository.findByPhone(dto.phone);
    if (!user) {
      throw new BusinessException('User not found', HttpStatus.NOT_FOUND);
    }

    await this.otpService.verifyPasswordResetOtp(dto.phone, dto.code);

    const passwordHash = await hashValue(dto.newPassword);
    await this.usersRepository.update(user.id, { passwordHash });
    await this.refreshTokenRepository.revokeAllForUser(user.id);

    await this.auditService.log({
      action: AuditAction.PASSWORD_CHANGE,
      entityType: 'User',
      entityId: user.id,
      userId: user.id,
      metadata: { event: 'reset_password' },
    });

    return { message: 'Password reset successful' };
  }

  private assertActiveUser(user: User, requestedRole: AppRole) {
    if (user.status === UserStatus.SUSPENDED) {
      throw new BusinessException('Account suspended', HttpStatus.FORBIDDEN);
    }

    if (user.status === UserStatus.DEACTIVATED) {
      throw new BusinessException('Account deactivated', HttpStatus.FORBIDDEN);
    }

    if (!user.phoneVerified || user.status !== UserStatus.ACTIVE) {
      throw new BusinessException(
        'Phone verification required',
        HttpStatus.FORBIDDEN,
      );
    }

    const storedRole = this.reverseMapRole(user.role);
    if (storedRole !== requestedRole) {
      throw new BusinessException('Role mismatch', HttpStatus.FORBIDDEN);
    }
  }

  private mapRole(role: AppRole): UserRole {
    return role === AppRole.EMPLOYEE ? UserRole.EMPLOYEE : UserRole.EMPLOYER;
  }

  toAppRole(role: UserRole): AppRole {
    return role === UserRole.EMPLOYEE ? AppRole.EMPLOYEE : AppRole.EMPLOYER;
  }

  private reverseMapRole(role: UserRole): AppRole {
    return this.toAppRole(role);
  }

  mapUser(user: User) {
    return {
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: this.reverseMapRole(user.role),
      phoneVerified: user.phoneVerified,
      status: user.status,
    };
  }
}

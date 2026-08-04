import { HttpStatus, Injectable } from '@nestjs/common';
import { AuthProvider, UserRole, UserStatus } from '@prisma/client';
import { AppRole } from '../../common/constants/roles.enum';
import { BusinessException } from '../../common/exceptions/business.exception';
import { AuditService } from '../../shared/audit/audit.service';
import { AuditAction } from '@prisma/client';
import { OAuthAccountRepository } from '../repositories/oauth-account.repository';
import { UsersRepository } from '../repositories/users.repository';
import { OtpService } from '../services/otp.service';
import { TokenService } from '../services/token.service';
import { AuthService } from '../auth.service';

export interface GoogleAuthUser {
  providerUserId: string;
  email?: string;
  name: string;
  role: AppRole;
}

@Injectable()
export class GoogleAuthService {
  constructor(
    private readonly oauthRepository: OAuthAccountRepository,
    private readonly usersRepository: UsersRepository,
    private readonly tokenService: TokenService,
    private readonly otpService: OtpService,
    private readonly authService: AuthService,
    private readonly auditService: AuditService,
  ) {}

  async handleCallback(
    googleUser: GoogleAuthUser,
    userAgent?: string,
    ipAddress?: string,
  ) {
    const existingOAuth = await this.oauthRepository.findByProvider(
      AuthProvider.GOOGLE,
      googleUser.providerUserId,
    );

    if (existingOAuth) {
      const user = existingOAuth.user;
      const role = this.authService.toAppRole(user.role);

      if (role !== googleUser.role) {
        throw new BusinessException('Role mismatch', HttpStatus.FORBIDDEN);
      }

      if (!user.phoneVerified || user.status !== UserStatus.ACTIVE) {
        throw new BusinessException(
          'Phone verification required. Bind phone via /auth/bind-phone',
          HttpStatus.FORBIDDEN,
          [{ message: 'phone_verification_required', field: 'phone' }],
        );
      }

      const tokens = await this.tokenService.issueUserTokens({
        userId: user.id,
        phone: user.phone,
        email: user.email,
        role,
        userAgent,
        ipAddress,
      });

      return { ...tokens, user: this.authService.mapUser(user) };
    }

    if (googleUser.email) {
      const existingEmail = await this.usersRepository.findByEmail(
        googleUser.email,
      );
      if (existingEmail) {
        throw new BusinessException(
          'Email already registered with different auth method',
          HttpStatus.CONFLICT,
        );
      }
    }

    const role =
      googleUser.role === AppRole.EMPLOYEE
        ? UserRole.EMPLOYEE
        : UserRole.EMPLOYER;

    const user = await this.usersRepository.create({
      name: googleUser.name,
      email: googleUser.email,
      phone: `+pending-${googleUser.providerUserId}`,
      role,
      status: UserStatus.PENDING_PHONE_VERIFICATION,
      passwordHash: null,
    });

    await this.usersRepository.createProfileForRole(user);
    await this.oauthRepository.create({
      provider: AuthProvider.GOOGLE,
      providerUserId: googleUser.providerUserId,
      user: { connect: { id: user.id } },
    });

    await this.auditService.log({
      action: AuditAction.CREATE,
      entityType: 'User',
      entityId: user.id,
      userId: user.id,
      metadata: { event: 'google_register' },
    });

    return {
      requiresPhoneBinding: true,
      userId: user.id,
      message: 'Google account linked. Bind and verify phone number.',
    };
  }

  async bindPhone(userId: string, phone: string, code?: string) {
    const user = await this.usersRepository.findById(userId);
    if (!user) {
      throw new BusinessException('User not found', HttpStatus.NOT_FOUND);
    }

    const existingPhone = await this.usersRepository.findByPhone(phone);
    if (existingPhone && existingPhone.id !== userId) {
      throw new BusinessException('Phone already in use', HttpStatus.CONFLICT);
    }

    if (!code) {
      await this.usersRepository.update(userId, { phone });
      await this.otpService.sendRegistrationOtp(phone);
      return { message: 'OTP sent to phone' };
    }

    await this.otpService.verifyRegistrationOtp(phone, code);
    const updated = await this.usersRepository.update(userId, {
      phone,
      phoneVerified: true,
      phoneVerifiedAt: new Date(),
      status: UserStatus.ACTIVE,
    });

    const role =
      updated.role === UserRole.EMPLOYEE ? AppRole.EMPLOYEE : AppRole.EMPLOYER;

    const tokens = await this.tokenService.issueUserTokens({
      userId: updated.id,
      phone: updated.phone,
      email: updated.email,
      role,
    });

    return { ...tokens, user: this.authService.mapUser(updated) };
  }
}

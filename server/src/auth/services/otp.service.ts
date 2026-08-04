import { HttpStatus, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { OtpPurpose } from '@prisma/client';
import { OTP_RESEND_LIMIT, OTP_RESEND_WINDOW_SECONDS } from '../../common/constants/app.constants';
import { BusinessException } from '../../common/exceptions/business.exception';
import { hashValue, verifyHash } from '../../common/utils/hash.util';
import { generateOtp } from '../../common/utils/token.util';
import { OtpRepository } from '../repositories/otp.repository';
import { SmsService } from '../../shared/sms/sms.service';

@Injectable()
export class OtpService {
  constructor(
    private readonly otpRepository: OtpRepository,
    private readonly sms: SmsService,
    private readonly configService: ConfigService,
  ) {}

  private get ttlSeconds() {
    return this.configService.get<number>('OTP_TTL_SECONDS') ?? 300;
  }

  private expiresAt() {
    return new Date(Date.now() + this.ttlSeconds * 1000);
  }

  async sendRegistrationOtp(phone: string): Promise<void> {
    await this.enforceResendLimit(phone);
    const code = generateOtp();
    const hash = await hashValue(code);
    await this.otpRepository.upsert({
      phone,
      purpose: OtpPurpose.REGISTRATION,
      codeHash: hash,
      expiresAt: this.expiresAt(),
    });
    await this.sms.sendOtp(phone, code);
  }

  async sendPasswordResetOtp(phone: string): Promise<void> {
    await this.enforceResendLimit(phone);
    const code = generateOtp();
    const hash = await hashValue(code);
    await this.otpRepository.upsert({
      phone,
      purpose: OtpPurpose.PASSWORD_RESET,
      codeHash: hash,
      expiresAt: this.expiresAt(),
    });
    await this.sms.sendOtp(phone, code);
  }

  async verifyRegistrationOtp(phone: string, code: string): Promise<void> {
    await this.verifyOtp(phone, OtpPurpose.REGISTRATION, code);
  }

  async verifyPasswordResetOtp(phone: string, code: string): Promise<void> {
    await this.verifyOtp(phone, OtpPurpose.PASSWORD_RESET, code);
  }

  private async verifyOtp(
    phone: string,
    purpose: OtpPurpose,
    code: string,
  ): Promise<void> {
    const stored = await this.otpRepository.findValid(phone, purpose);
    if (!stored) {
      throw new BusinessException('OTP expired or not found', HttpStatus.BAD_REQUEST);
    }

    const valid = await verifyHash(stored.codeHash, code);
    if (!valid) {
      throw new BusinessException('Invalid OTP', HttpStatus.BAD_REQUEST);
    }

    await this.otpRepository.delete(phone, purpose);
  }

  private async enforceResendLimit(phone: string) {
    const record = await this.otpRepository.incrementResendCount(
      phone,
      OTP_RESEND_WINDOW_SECONDS,
    );

    if (record.attempts > OTP_RESEND_LIMIT) {
      throw new BusinessException(
        'OTP resend limit exceeded',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }
  }
}

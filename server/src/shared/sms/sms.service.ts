import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import twilio from 'twilio';

@Injectable()
export class SmsService {
  private readonly logger = new Logger(SmsService.name);
  private readonly client: ReturnType<typeof twilio> | null;
  private readonly fromNumber: string | null;

  constructor(private readonly configService: ConfigService) {
    const accountSid = this.configService.get<string>('TWILIO_ACCOUNT_SID');
    const authToken = this.configService.get<string>('TWILIO_AUTH_TOKEN');
    this.fromNumber = this.configService.get<string>('TWILIO_PHONE_NUMBER') ?? null;

    if (accountSid && authToken) {
      this.client = twilio(accountSid, authToken);
    } else {
      this.client = null;
    }
  }

  async sendOtp(phone: string, code: string): Promise<void> {
    const message = `Your Job Portal verification code is ${code}. Valid for 5 minutes.`;

    if (!this.client || !this.fromNumber) {
      this.logger.warn(`SMS skipped (Twilio not configured). Phone: ${phone}`);
      if (process.env.NODE_ENV === 'development') {
        this.logger.warn(`[DEV ONLY] OTP for ${phone}: ${code}`);
      }
      return;
    }

    await this.client.messages.create({
      body: message,
      from: this.fromNumber,
      to: phone,
    });
  }
}

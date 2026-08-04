import { ConfigService } from '@nestjs/config';
import { OtpRepository } from '../repositories/otp.repository';
import { SmsService } from '../../shared/sms/sms.service';
export declare class OtpService {
    private readonly otpRepository;
    private readonly sms;
    private readonly configService;
    constructor(otpRepository: OtpRepository, sms: SmsService, configService: ConfigService);
    private get ttlSeconds();
    private expiresAt;
    sendRegistrationOtp(phone: string): Promise<void>;
    sendPasswordResetOtp(phone: string): Promise<void>;
    verifyRegistrationOtp(phone: string, code: string): Promise<void>;
    verifyPasswordResetOtp(phone: string, code: string): Promise<void>;
    private verifyOtp;
    private enforceResendLimit;
}

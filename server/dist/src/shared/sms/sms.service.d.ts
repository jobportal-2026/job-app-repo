import { ConfigService } from '@nestjs/config';
export declare class SmsService {
    private readonly configService;
    private readonly logger;
    private readonly client;
    private readonly fromNumber;
    constructor(configService: ConfigService);
    sendOtp(phone: string, code: string): Promise<void>;
}

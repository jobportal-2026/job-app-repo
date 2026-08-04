import { ConfigService } from '@nestjs/config';
export declare class MailService {
    private readonly configService;
    private readonly logger;
    private readonly transporter;
    constructor(configService: ConfigService);
    sendMail(to: string, subject: string, text: string): Promise<void>;
}

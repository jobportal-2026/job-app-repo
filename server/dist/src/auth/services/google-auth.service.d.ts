import { AppRole } from '../../common/constants/roles.enum';
import { AuditService } from '../../shared/audit/audit.service';
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
export declare class GoogleAuthService {
    private readonly oauthRepository;
    private readonly usersRepository;
    private readonly tokenService;
    private readonly otpService;
    private readonly authService;
    private readonly auditService;
    constructor(oauthRepository: OAuthAccountRepository, usersRepository: UsersRepository, tokenService: TokenService, otpService: OtpService, authService: AuthService, auditService: AuditService);
    handleCallback(googleUser: GoogleAuthUser, userAgent?: string, ipAddress?: string): Promise<{
        user: {
            id: string;
            name: string;
            email: string | null;
            phone: string;
            role: AppRole;
            phoneVerified: boolean;
            status: import("@prisma/client").$Enums.UserStatus;
        };
        accessToken: string;
        refreshToken: string;
        requiresPhoneBinding?: undefined;
        userId?: undefined;
        message?: undefined;
    } | {
        requiresPhoneBinding: boolean;
        userId: string;
        message: string;
    }>;
    bindPhone(userId: string, phone: string, code?: string): Promise<{
        message: string;
    } | {
        user: {
            id: string;
            name: string;
            email: string | null;
            phone: string;
            role: AppRole;
            phoneVerified: boolean;
            status: import("@prisma/client").$Enums.UserStatus;
        };
        accessToken: string;
        refreshToken: string;
        message?: undefined;
    }>;
}

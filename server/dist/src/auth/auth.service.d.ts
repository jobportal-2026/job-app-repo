import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { User, UserRole } from '@prisma/client';
import { AppRole } from '../common/constants/roles.enum';
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
export declare class AuthService {
    private readonly usersRepository;
    private readonly refreshTokenRepository;
    private readonly revokedTokenRepository;
    private readonly otpService;
    private readonly tokenService;
    private readonly jwtService;
    private readonly configService;
    private readonly auditService;
    private readonly prisma;
    constructor(usersRepository: UsersRepository, refreshTokenRepository: RefreshTokenRepository, revokedTokenRepository: RevokedTokenRepository, otpService: OtpService, tokenService: TokenService, jwtService: JwtService, configService: ConfigService, auditService: AuditService, prisma: PrismaService);
    register(dto: RegisterDto): Promise<{
        message: string;
        userId: string;
        phone: string;
    }>;
    verifyPhone(phone: string, code: string): Promise<{
        id: string;
        name: string;
        email: string | null;
        phone: string;
        role: AppRole;
        phoneVerified: boolean;
        status: import("@prisma/client").$Enums.UserStatus;
    }>;
    resendOtp(phone: string): Promise<{
        message: string;
    }>;
    login(dto: LoginDto, userAgent?: string, ipAddress?: string): Promise<{
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
    }>;
    refresh(refreshToken: string, userAgent?: string, ipAddress?: string): Promise<{
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
    }>;
    logout(userId: string, accessJti: string, accessExp?: number, refreshToken?: string): Promise<{
        message: string;
    }>;
    getCurrentUser(userId: string): Promise<{
        id: string;
        name: string;
        email: string | null;
        phone: string;
        role: AppRole;
        phoneVerified: boolean;
        status: import("@prisma/client").$Enums.UserStatus;
    }>;
    changePassword(userId: string, dto: ChangePasswordDto): Promise<{
        message: string;
    }>;
    forgotPassword(dto: ForgotPasswordDto): Promise<{
        message: string;
    }>;
    resetPassword(dto: ResetPasswordDto): Promise<{
        message: string;
    }>;
    private assertActiveUser;
    private mapRole;
    toAppRole(role: UserRole): AppRole;
    private reverseMapRole;
    mapUser(user: User): {
        id: string;
        name: string;
        email: string | null;
        phone: string;
        role: AppRole;
        phoneVerified: boolean;
        status: import("@prisma/client").$Enums.UserStatus;
    };
}

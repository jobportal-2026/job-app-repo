import type { Request, Response } from 'express';
import type { JwtPayload } from '../common/interfaces/jwt-payload.interface';
import { AuthService } from './auth.service';
import { ChangePasswordDto } from './dto/change-password.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { RegisterDto } from './dto/register.dto';
import { ResendOtpDto } from './dto/resend-otp.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { VerifyPhoneDto } from './dto/verify-phone.dto';
import { GoogleAuthService } from './services/google-auth.service';
import { BindPhoneDto } from './dto/google-auth.dto';
import { AppRole } from '../common/constants/roles.enum';
export declare class AuthController {
    private readonly authService;
    private readonly googleAuthService;
    constructor(authService: AuthService, googleAuthService: GoogleAuthService);
    register(dto: RegisterDto): Promise<{
        message: string;
        userId: string;
        phone: string;
    }>;
    verifyPhone(dto: VerifyPhoneDto): Promise<{
        id: string;
        name: string;
        email: string | null;
        phone: string;
        role: AppRole;
        phoneVerified: boolean;
        status: import("@prisma/client").$Enums.UserStatus;
    }>;
    resendOtp(dto: ResendOtpDto): Promise<{
        message: string;
    }>;
    login(dto: LoginDto, userAgent?: string, req?: Request): Promise<{
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
    refresh(dto: RefreshTokenDto, userAgent?: string, req?: Request): Promise<{
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
    logout(user: JwtPayload, body: Partial<RefreshTokenDto>): Promise<{
        message: string;
    }>;
    me(user: JwtPayload): Promise<{
        id: string;
        name: string;
        email: string | null;
        phone: string;
        role: AppRole;
        phoneVerified: boolean;
        status: import("@prisma/client").$Enums.UserStatus;
    }>;
    changePassword(user: JwtPayload, dto: ChangePasswordDto): Promise<{
        message: string;
    }>;
    forgotPassword(dto: ForgotPasswordDto): Promise<{
        message: string;
    }>;
    resetPassword(dto: ResetPasswordDto): Promise<{
        message: string;
    }>;
    googleAuth(): void;
    googleCallback(req: Request, res: Response, userAgent?: string): Promise<Response<any, Record<string, any>>>;
    bindPhone(dto: BindPhoneDto): Promise<{
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

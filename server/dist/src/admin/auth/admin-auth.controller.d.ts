import type { Request } from 'express';
import { RefreshTokenDto } from '../../auth/dto/refresh-token.dto';
import { AdminAuthService } from './admin-auth.service';
import { AdminLoginDto } from './dto/admin-login.dto';
import type { AdminJwtPayload } from '../../common/interfaces/jwt-payload.interface';
export declare class AdminAuthController {
    private readonly adminAuthService;
    constructor(adminAuthService: AdminAuthService);
    login(dto: AdminLoginDto, userAgent?: string, req?: Request): Promise<{
        accessToken: string;
        refreshToken: string;
        admin: {
            id: string;
            email: string;
            name: string;
            permissions: string[];
        };
    }>;
    refresh(dto: RefreshTokenDto, userAgent?: string, req?: Request): Promise<{
        accessToken: string;
        refreshToken: string;
        admin: {
            id: string;
            email: string;
            name: string;
            permissions: string[];
        };
    }>;
    logout(admin: AdminJwtPayload, body: Partial<RefreshTokenDto>): Promise<{
        message: string;
    }>;
    me(admin: AdminJwtPayload): Promise<{
        id: string;
        email: string;
        name: string;
        permissions: string[];
    }>;
}

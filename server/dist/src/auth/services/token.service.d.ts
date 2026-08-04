import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { AppRole } from '../../common/constants/roles.enum';
import { RefreshTokenRepository } from '../repositories/refresh-token.repository';
export declare class TokenService {
    private readonly jwtService;
    private readonly configService;
    private readonly refreshTokenRepository;
    constructor(jwtService: JwtService, configService: ConfigService, refreshTokenRepository: RefreshTokenRepository);
    issueUserTokens(params: {
        userId: string;
        phone: string;
        email?: string | null;
        role: AppRole;
        userAgent?: string;
        ipAddress?: string;
    }): Promise<{
        accessToken: string;
        refreshToken: string;
    }>;
    issueAdminTokens(params: {
        adminId: string;
        email: string;
        permissions: string[];
        userAgent?: string;
        ipAddress?: string;
    }): Promise<{
        accessToken: string;
        refreshToken: string;
        refreshJti: `${string}-${string}-${string}-${string}-${string}`;
    }>;
    private calculateExpiry;
}

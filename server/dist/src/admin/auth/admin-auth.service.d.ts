import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { AuditService } from '../../shared/audit/audit.service';
import { AdminLoginDto } from './dto/admin-login.dto';
import { AdminRepository } from './repositories/admin.repository';
export declare class AdminAuthService {
    private readonly adminRepository;
    private readonly jwtService;
    private readonly configService;
    private readonly auditService;
    constructor(adminRepository: AdminRepository, jwtService: JwtService, configService: ConfigService, auditService: AuditService);
    login(dto: AdminLoginDto, userAgent?: string, ipAddress?: string): Promise<{
        accessToken: string;
        refreshToken: string;
        admin: {
            id: string;
            email: string;
            name: string;
            permissions: string[];
        };
    }>;
    refresh(refreshToken: string, userAgent?: string, ipAddress?: string): Promise<{
        accessToken: string;
        refreshToken: string;
        admin: {
            id: string;
            email: string;
            name: string;
            permissions: string[];
        };
    }>;
    private issueTokens;
    logout(adminId: string, refreshToken?: string): Promise<{
        message: string;
    }>;
    me(adminId: string): Promise<{
        id: string;
        email: string;
        name: string;
        permissions: string[];
    }>;
}

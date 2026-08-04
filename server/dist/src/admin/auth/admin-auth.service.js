"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdminAuthService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const jwt_1 = require("@nestjs/jwt");
const client_1 = require("@prisma/client");
const business_exception_1 = require("../../common/exceptions/business.exception");
const hash_util_1 = require("../../common/utils/hash.util");
const jwt_util_1 = require("../../common/utils/jwt.util");
const audit_service_1 = require("../../shared/audit/audit.service");
const admin_repository_1 = require("./repositories/admin.repository");
let AdminAuthService = class AdminAuthService {
    adminRepository;
    jwtService;
    configService;
    auditService;
    constructor(adminRepository, jwtService, configService, auditService) {
        this.adminRepository = adminRepository;
        this.jwtService = jwtService;
        this.configService = configService;
        this.auditService = auditService;
    }
    async login(dto, userAgent, ipAddress) {
        const admin = await this.adminRepository.findByEmail(dto.email);
        if (!admin || !admin.isActive) {
            throw new business_exception_1.BusinessException('Invalid credentials', common_1.HttpStatus.UNAUTHORIZED);
        }
        const valid = await (0, hash_util_1.verifyHash)(admin.passwordHash, dto.password);
        if (!valid) {
            throw new business_exception_1.BusinessException('Invalid credentials', common_1.HttpStatus.UNAUTHORIZED);
        }
        await this.adminRepository.updateLastLogin(admin.id);
        await this.auditService.log({
            action: client_1.AuditAction.LOGIN,
            entityType: 'Admin',
            entityId: admin.id,
            adminId: admin.id,
            ipAddress,
            userAgent,
        });
        return this.issueTokens(admin, userAgent, ipAddress);
    }
    async refresh(refreshToken, userAgent, ipAddress) {
        let payload;
        try {
            payload = await this.jwtService.verifyAsync(refreshToken, {
                secret: this.configService.get('ADMIN_JWT_REFRESH_SECRET'),
            });
        }
        catch {
            throw new business_exception_1.BusinessException('Invalid refresh token', common_1.HttpStatus.UNAUTHORIZED);
        }
        const tokens = await this.adminRepository.findActiveRefreshTokens(payload.sub);
        let matchedId = null;
        for (const stored of tokens) {
            const valid = await (0, hash_util_1.verifyHash)(stored.tokenHash, refreshToken);
            if (valid) {
                matchedId = stored.id;
                break;
            }
        }
        if (!matchedId) {
            throw new business_exception_1.BusinessException('Invalid refresh token', common_1.HttpStatus.UNAUTHORIZED);
        }
        await this.adminRepository.revokeRefreshToken(matchedId);
        const admin = await this.adminRepository.findById(payload.sub);
        if (!admin || !admin.isActive) {
            throw new business_exception_1.BusinessException('Admin not found', common_1.HttpStatus.NOT_FOUND);
        }
        return this.issueTokens(admin, userAgent, ipAddress);
    }
    async issueTokens(admin, userAgent, ipAddress) {
        const jti = crypto.randomUUID();
        const accessToken = await this.jwtService.signAsync({
            sub: admin.id,
            email: admin.email,
            permissions: admin.permissions,
            jti,
            type: 'admin_access',
        }, {
            secret: this.configService.get('ADMIN_JWT_SECRET'),
            expiresIn: (0, jwt_util_1.jwtExpiresIn)(this.configService.get('JWT_ACCESS_EXPIRES_IN'), '15m'),
        });
        const refreshToken = await this.jwtService.signAsync({
            sub: admin.id,
            jti: crypto.randomUUID(),
            type: 'admin_refresh',
        }, {
            secret: this.configService.get('ADMIN_JWT_REFRESH_SECRET'),
            expiresIn: (0, jwt_util_1.jwtExpiresIn)(this.configService.get('JWT_REFRESH_EXPIRES_IN'), '7d'),
        });
        await this.adminRepository.createRefreshToken({
            tokenHash: await (0, hash_util_1.hashValue)(refreshToken),
            admin: { connect: { id: admin.id } },
            userAgent,
            ipAddress,
            expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
        });
        return {
            accessToken,
            refreshToken,
            admin: {
                id: admin.id,
                email: admin.email,
                name: admin.name,
                permissions: admin.permissions,
            },
        };
    }
    async logout(adminId, refreshToken) {
        if (refreshToken) {
            const tokens = await this.adminRepository.findActiveRefreshTokens(adminId);
            for (const stored of tokens) {
                const valid = await (0, hash_util_1.verifyHash)(stored.tokenHash, refreshToken);
                if (valid) {
                    await this.adminRepository.revokeRefreshToken(stored.id);
                    break;
                }
            }
        }
        else {
            await this.adminRepository.revokeAllRefreshTokens(adminId);
        }
        await this.auditService.log({
            action: client_1.AuditAction.LOGOUT,
            entityType: 'Admin',
            entityId: adminId,
            adminId,
        });
        return { message: 'Logged out successfully' };
    }
    async me(adminId) {
        const admin = await this.adminRepository.findById(adminId);
        if (!admin || !admin.isActive) {
            throw new business_exception_1.BusinessException('Admin not found', common_1.HttpStatus.NOT_FOUND);
        }
        return {
            id: admin.id,
            email: admin.email,
            name: admin.name,
            permissions: admin.permissions,
        };
    }
};
exports.AdminAuthService = AdminAuthService;
exports.AdminAuthService = AdminAuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [admin_repository_1.AdminRepository,
        jwt_1.JwtService,
        config_1.ConfigService,
        audit_service_1.AuditService])
], AdminAuthService);
//# sourceMappingURL=admin-auth.service.js.map
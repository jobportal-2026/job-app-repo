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
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const config_1 = require("@nestjs/config");
const client_1 = require("@prisma/client");
const roles_enum_1 = require("../common/constants/roles.enum");
const business_exception_1 = require("../common/exceptions/business.exception");
const hash_util_1 = require("../common/utils/hash.util");
const sanitize_util_1 = require("../common/utils/sanitize.util");
const audit_service_1 = require("../shared/audit/audit.service");
const prisma_service_1 = require("../database/prisma.service");
const refresh_token_repository_1 = require("./repositories/refresh-token.repository");
const revoked_token_repository_1 = require("./repositories/revoked-token.repository");
const users_repository_1 = require("./repositories/users.repository");
const otp_service_1 = require("./services/otp.service");
const token_service_1 = require("./services/token.service");
let AuthService = class AuthService {
    usersRepository;
    refreshTokenRepository;
    revokedTokenRepository;
    otpService;
    tokenService;
    jwtService;
    configService;
    auditService;
    prisma;
    constructor(usersRepository, refreshTokenRepository, revokedTokenRepository, otpService, tokenService, jwtService, configService, auditService, prisma) {
        this.usersRepository = usersRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.revokedTokenRepository = revokedTokenRepository;
        this.otpService = otpService;
        this.tokenService = tokenService;
        this.jwtService = jwtService;
        this.configService = configService;
        this.auditService = auditService;
        this.prisma = prisma;
    }
    async register(dto) {
        const phone = dto.phone;
        const existingPhone = await this.usersRepository.findByPhone(phone);
        if (existingPhone) {
            throw new business_exception_1.BusinessException('Phone already registered', common_1.HttpStatus.CONFLICT);
        }
        if (dto.email) {
            const existingEmail = await this.usersRepository.findByEmail(dto.email);
            if (existingEmail) {
                throw new business_exception_1.BusinessException('Email already registered', common_1.HttpStatus.CONFLICT);
            }
        }
        const passwordHash = await (0, hash_util_1.hashValue)(dto.password);
        const role = this.mapRole(dto.role);
        const user = await this.usersRepository.create({
            name: (0, sanitize_util_1.sanitizeText)(dto.name),
            email: dto.email,
            phone,
            passwordHash,
            role,
            status: client_1.UserStatus.PENDING_PHONE_VERIFICATION,
        });
        await this.usersRepository.createProfileForRole(user);
        await this.otpService.sendRegistrationOtp(phone);
        await this.auditService.log({
            action: client_1.AuditAction.CREATE,
            entityType: 'User',
            entityId: user.id,
            userId: user.id,
            metadata: { event: 'register' },
        });
        return {
            message: 'Registration successful. Verify phone with OTP.',
            userId: user.id,
            phone: user.phone,
        };
    }
    async verifyPhone(phone, code) {
        const user = await this.usersRepository.findByPhone(phone);
        if (!user) {
            throw new business_exception_1.BusinessException('User not found', common_1.HttpStatus.NOT_FOUND);
        }
        await this.otpService.verifyRegistrationOtp(phone, code);
        const updated = await this.usersRepository.update(user.id, {
            phoneVerified: true,
            phoneVerifiedAt: new Date(),
            status: client_1.UserStatus.ACTIVE,
        });
        await this.auditService.log({
            action: client_1.AuditAction.PHONE_VERIFY,
            entityType: 'User',
            entityId: user.id,
            userId: user.id,
        });
        return this.mapUser(updated);
    }
    async resendOtp(phone) {
        const user = await this.usersRepository.findByPhone(phone);
        if (!user) {
            throw new business_exception_1.BusinessException('User not found', common_1.HttpStatus.NOT_FOUND);
        }
        if (user.phoneVerified) {
            throw new business_exception_1.BusinessException('Phone already verified', common_1.HttpStatus.BAD_REQUEST);
        }
        await this.otpService.sendRegistrationOtp(phone);
        return { message: 'OTP sent' };
    }
    async login(dto, userAgent, ipAddress) {
        const user = await this.usersRepository.findByEmail(dto.email);
        if (!user || !user.passwordHash) {
            throw new business_exception_1.BusinessException('Invalid credentials', common_1.HttpStatus.UNAUTHORIZED);
        }
        const validPassword = await (0, hash_util_1.verifyHash)(user.passwordHash, dto.password);
        if (!validPassword) {
            throw new business_exception_1.BusinessException('Invalid credentials', common_1.HttpStatus.UNAUTHORIZED);
        }
        this.assertActiveUser(user, dto.role);
        const tokens = await this.tokenService.issueUserTokens({
            userId: user.id,
            phone: user.phone,
            email: user.email,
            role: dto.role,
            userAgent,
            ipAddress,
        });
        await this.usersRepository.update(user.id, { lastLoginAt: new Date() });
        await this.auditService.log({
            action: client_1.AuditAction.LOGIN,
            entityType: 'User',
            entityId: user.id,
            userId: user.id,
            ipAddress,
            userAgent,
        });
        return {
            ...tokens,
            user: this.mapUser(user),
        };
    }
    async refresh(refreshToken, userAgent, ipAddress) {
        let payload;
        try {
            payload = await this.jwtService.verifyAsync(refreshToken, { secret: this.configService.get('JWT_REFRESH_SECRET') });
        }
        catch {
            throw new business_exception_1.BusinessException('Invalid refresh token', common_1.HttpStatus.UNAUTHORIZED);
        }
        if (payload.type !== 'refresh') {
            throw new business_exception_1.BusinessException('Invalid refresh token', common_1.HttpStatus.UNAUTHORIZED);
        }
        const tokens = await this.refreshTokenRepository.findActiveByUserId(payload.sub);
        let matchedTokenId = null;
        for (const stored of tokens) {
            const valid = await (0, hash_util_1.verifyHash)(stored.tokenHash, refreshToken);
            if (valid) {
                matchedTokenId = stored.id;
                break;
            }
        }
        if (!matchedTokenId) {
            throw new business_exception_1.BusinessException('Invalid refresh token', common_1.HttpStatus.UNAUTHORIZED);
        }
        await this.refreshTokenRepository.revoke(matchedTokenId);
        const user = await this.usersRepository.findById(payload.sub);
        if (!user) {
            throw new business_exception_1.BusinessException('User not found', common_1.HttpStatus.NOT_FOUND);
        }
        const role = this.reverseMapRole(user.role);
        const newTokens = await this.tokenService.issueUserTokens({
            userId: user.id,
            phone: user.phone,
            email: user.email,
            role,
            userAgent,
            ipAddress,
        });
        return {
            ...newTokens,
            user: this.mapUser(user),
        };
    }
    async logout(userId, accessJti, accessExp, refreshToken) {
        if (accessJti) {
            const expiresAt = accessExp
                ? new Date(accessExp * 1000)
                : new Date(Date.now() + 15 * 60 * 1000);
            await this.revokedTokenRepository.revoke(accessJti, expiresAt);
        }
        if (refreshToken) {
            const tokens = await this.refreshTokenRepository.findActiveByUserId(userId);
            for (const stored of tokens) {
                const valid = await (0, hash_util_1.verifyHash)(stored.tokenHash, refreshToken);
                if (valid) {
                    await this.refreshTokenRepository.revoke(stored.id);
                    break;
                }
            }
        }
        else {
            await this.refreshTokenRepository.revokeAllForUser(userId);
        }
        await this.auditService.log({
            action: client_1.AuditAction.LOGOUT,
            entityType: 'User',
            entityId: userId,
            userId,
        });
        return { message: 'Logged out successfully' };
    }
    async getCurrentUser(userId) {
        const user = await this.usersRepository.findById(userId);
        if (!user) {
            throw new business_exception_1.BusinessException('User not found', common_1.HttpStatus.NOT_FOUND);
        }
        return this.mapUser(user);
    }
    async changePassword(userId, dto) {
        const user = await this.usersRepository.findById(userId);
        if (!user || !user.passwordHash) {
            throw new business_exception_1.BusinessException('User not found', common_1.HttpStatus.NOT_FOUND);
        }
        const valid = await (0, hash_util_1.verifyHash)(user.passwordHash, dto.currentPassword);
        if (!valid) {
            throw new business_exception_1.BusinessException('Current password is incorrect', common_1.HttpStatus.BAD_REQUEST);
        }
        const passwordHash = await (0, hash_util_1.hashValue)(dto.newPassword);
        await this.usersRepository.update(userId, { passwordHash });
        await this.refreshTokenRepository.revokeAllForUser(userId);
        await this.auditService.log({
            action: client_1.AuditAction.PASSWORD_CHANGE,
            entityType: 'User',
            entityId: userId,
            userId,
        });
        return { message: 'Password changed successfully' };
    }
    async forgotPassword(dto) {
        const user = await this.usersRepository.findByPhone(dto.phone);
        if (!user) {
            return { message: 'If the phone exists, an OTP has been sent' };
        }
        await this.otpService.sendPasswordResetOtp(dto.phone);
        return { message: 'If the phone exists, an OTP has been sent' };
    }
    async resetPassword(dto) {
        const user = await this.usersRepository.findByPhone(dto.phone);
        if (!user) {
            throw new business_exception_1.BusinessException('User not found', common_1.HttpStatus.NOT_FOUND);
        }
        await this.otpService.verifyPasswordResetOtp(dto.phone, dto.code);
        const passwordHash = await (0, hash_util_1.hashValue)(dto.newPassword);
        await this.usersRepository.update(user.id, { passwordHash });
        await this.refreshTokenRepository.revokeAllForUser(user.id);
        await this.auditService.log({
            action: client_1.AuditAction.PASSWORD_CHANGE,
            entityType: 'User',
            entityId: user.id,
            userId: user.id,
            metadata: { event: 'reset_password' },
        });
        return { message: 'Password reset successful' };
    }
    assertActiveUser(user, requestedRole) {
        if (user.status === client_1.UserStatus.SUSPENDED) {
            throw new business_exception_1.BusinessException('Account suspended', common_1.HttpStatus.FORBIDDEN);
        }
        if (user.status === client_1.UserStatus.DEACTIVATED) {
            throw new business_exception_1.BusinessException('Account deactivated', common_1.HttpStatus.FORBIDDEN);
        }
        if (!user.phoneVerified || user.status !== client_1.UserStatus.ACTIVE) {
            throw new business_exception_1.BusinessException('Phone verification required', common_1.HttpStatus.FORBIDDEN);
        }
        const storedRole = this.reverseMapRole(user.role);
        if (storedRole !== requestedRole) {
            throw new business_exception_1.BusinessException('Role mismatch', common_1.HttpStatus.FORBIDDEN);
        }
    }
    mapRole(role) {
        return role === roles_enum_1.AppRole.EMPLOYEE ? client_1.UserRole.EMPLOYEE : client_1.UserRole.EMPLOYER;
    }
    toAppRole(role) {
        return role === client_1.UserRole.EMPLOYEE ? roles_enum_1.AppRole.EMPLOYEE : roles_enum_1.AppRole.EMPLOYER;
    }
    reverseMapRole(role) {
        return this.toAppRole(role);
    }
    mapUser(user) {
        return {
            id: user.id,
            name: user.name,
            email: user.email,
            phone: user.phone,
            role: this.reverseMapRole(user.role),
            phoneVerified: user.phoneVerified,
            status: user.status,
        };
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [users_repository_1.UsersRepository,
        refresh_token_repository_1.RefreshTokenRepository,
        revoked_token_repository_1.RevokedTokenRepository,
        otp_service_1.OtpService,
        token_service_1.TokenService,
        jwt_1.JwtService,
        config_1.ConfigService,
        audit_service_1.AuditService,
        prisma_service_1.PrismaService])
], AuthService);
//# sourceMappingURL=auth.service.js.map
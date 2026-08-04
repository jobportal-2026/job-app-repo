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
exports.GoogleAuthService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const roles_enum_1 = require("../../common/constants/roles.enum");
const business_exception_1 = require("../../common/exceptions/business.exception");
const audit_service_1 = require("../../shared/audit/audit.service");
const client_2 = require("@prisma/client");
const oauth_account_repository_1 = require("../repositories/oauth-account.repository");
const users_repository_1 = require("../repositories/users.repository");
const otp_service_1 = require("../services/otp.service");
const token_service_1 = require("../services/token.service");
const auth_service_1 = require("../auth.service");
let GoogleAuthService = class GoogleAuthService {
    oauthRepository;
    usersRepository;
    tokenService;
    otpService;
    authService;
    auditService;
    constructor(oauthRepository, usersRepository, tokenService, otpService, authService, auditService) {
        this.oauthRepository = oauthRepository;
        this.usersRepository = usersRepository;
        this.tokenService = tokenService;
        this.otpService = otpService;
        this.authService = authService;
        this.auditService = auditService;
    }
    async handleCallback(googleUser, userAgent, ipAddress) {
        const existingOAuth = await this.oauthRepository.findByProvider(client_1.AuthProvider.GOOGLE, googleUser.providerUserId);
        if (existingOAuth) {
            const user = existingOAuth.user;
            const role = this.authService.toAppRole(user.role);
            if (role !== googleUser.role) {
                throw new business_exception_1.BusinessException('Role mismatch', common_1.HttpStatus.FORBIDDEN);
            }
            if (!user.phoneVerified || user.status !== client_1.UserStatus.ACTIVE) {
                throw new business_exception_1.BusinessException('Phone verification required. Bind phone via /auth/bind-phone', common_1.HttpStatus.FORBIDDEN, [{ message: 'phone_verification_required', field: 'phone' }]);
            }
            const tokens = await this.tokenService.issueUserTokens({
                userId: user.id,
                phone: user.phone,
                email: user.email,
                role,
                userAgent,
                ipAddress,
            });
            return { ...tokens, user: this.authService.mapUser(user) };
        }
        if (googleUser.email) {
            const existingEmail = await this.usersRepository.findByEmail(googleUser.email);
            if (existingEmail) {
                throw new business_exception_1.BusinessException('Email already registered with different auth method', common_1.HttpStatus.CONFLICT);
            }
        }
        const role = googleUser.role === roles_enum_1.AppRole.EMPLOYEE
            ? client_1.UserRole.EMPLOYEE
            : client_1.UserRole.EMPLOYER;
        const user = await this.usersRepository.create({
            name: googleUser.name,
            email: googleUser.email,
            phone: `+pending-${googleUser.providerUserId}`,
            role,
            status: client_1.UserStatus.PENDING_PHONE_VERIFICATION,
            passwordHash: null,
        });
        await this.usersRepository.createProfileForRole(user);
        await this.oauthRepository.create({
            provider: client_1.AuthProvider.GOOGLE,
            providerUserId: googleUser.providerUserId,
            user: { connect: { id: user.id } },
        });
        await this.auditService.log({
            action: client_2.AuditAction.CREATE,
            entityType: 'User',
            entityId: user.id,
            userId: user.id,
            metadata: { event: 'google_register' },
        });
        return {
            requiresPhoneBinding: true,
            userId: user.id,
            message: 'Google account linked. Bind and verify phone number.',
        };
    }
    async bindPhone(userId, phone, code) {
        const user = await this.usersRepository.findById(userId);
        if (!user) {
            throw new business_exception_1.BusinessException('User not found', common_1.HttpStatus.NOT_FOUND);
        }
        const existingPhone = await this.usersRepository.findByPhone(phone);
        if (existingPhone && existingPhone.id !== userId) {
            throw new business_exception_1.BusinessException('Phone already in use', common_1.HttpStatus.CONFLICT);
        }
        if (!code) {
            await this.usersRepository.update(userId, { phone });
            await this.otpService.sendRegistrationOtp(phone);
            return { message: 'OTP sent to phone' };
        }
        await this.otpService.verifyRegistrationOtp(phone, code);
        const updated = await this.usersRepository.update(userId, {
            phone,
            phoneVerified: true,
            phoneVerifiedAt: new Date(),
            status: client_1.UserStatus.ACTIVE,
        });
        const role = updated.role === client_1.UserRole.EMPLOYEE ? roles_enum_1.AppRole.EMPLOYEE : roles_enum_1.AppRole.EMPLOYER;
        const tokens = await this.tokenService.issueUserTokens({
            userId: updated.id,
            phone: updated.phone,
            email: updated.email,
            role,
        });
        return { ...tokens, user: this.authService.mapUser(updated) };
    }
};
exports.GoogleAuthService = GoogleAuthService;
exports.GoogleAuthService = GoogleAuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [oauth_account_repository_1.OAuthAccountRepository,
        users_repository_1.UsersRepository,
        token_service_1.TokenService,
        otp_service_1.OtpService,
        auth_service_1.AuthService,
        audit_service_1.AuditService])
], GoogleAuthService);
//# sourceMappingURL=google-auth.service.js.map
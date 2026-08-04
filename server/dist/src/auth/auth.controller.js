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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const current_user_decorator_1 = require("../common/decorators/current-user.decorator");
const public_decorator_1 = require("../common/decorators/public.decorator");
const auth_service_1 = require("./auth.service");
const change_password_dto_1 = require("./dto/change-password.dto");
const forgot_password_dto_1 = require("./dto/forgot-password.dto");
const login_dto_1 = require("./dto/login.dto");
const refresh_token_dto_1 = require("./dto/refresh-token.dto");
const register_dto_1 = require("./dto/register.dto");
const resend_otp_dto_1 = require("./dto/resend-otp.dto");
const reset_password_dto_1 = require("./dto/reset-password.dto");
const verify_phone_dto_1 = require("./dto/verify-phone.dto");
const google_auth_guard_1 = require("./guards/google-auth.guard");
const google_oauth_config_guard_1 = require("./guards/google-oauth-config.guard");
const google_auth_service_1 = require("./services/google-auth.service");
const google_auth_dto_1 = require("./dto/google-auth.dto");
let AuthController = class AuthController {
    authService;
    googleAuthService;
    constructor(authService, googleAuthService) {
        this.authService = authService;
        this.googleAuthService = googleAuthService;
    }
    register(dto) {
        return this.authService.register(dto);
    }
    verifyPhone(dto) {
        return this.authService.verifyPhone(dto.phone, dto.code);
    }
    resendOtp(dto) {
        return this.authService.resendOtp(dto.phone);
    }
    login(dto, userAgent, req) {
        return this.authService.login(dto, userAgent, req?.ip);
    }
    refresh(dto, userAgent, req) {
        return this.authService.refresh(dto.refreshToken, userAgent, req?.ip);
    }
    logout(user, body) {
        return this.authService.logout(user.sub, user.jti, user.exp, body.refreshToken);
    }
    me(user) {
        return this.authService.getCurrentUser(user.sub);
    }
    changePassword(user, dto) {
        return this.authService.changePassword(user.sub, dto);
    }
    forgotPassword(dto) {
        return this.authService.forgotPassword(dto);
    }
    resetPassword(dto) {
        return this.authService.resetPassword(dto);
    }
    googleAuth() {
        return;
    }
    async googleCallback(req, res, userAgent) {
        const result = await this.googleAuthService.handleCallback(req.user, userAgent, req.ip);
        return res.json({
            success: true,
            message: '',
            data: result,
        });
    }
    bindPhone(dto) {
        return this.googleAuthService.bindPhone(dto.userId, dto.phone, dto.code);
    }
};
exports.AuthController = AuthController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('register'),
    (0, swagger_1.ApiOperation)({ summary: 'Register employee or employer' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [register_dto_1.RegisterDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "register", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('verify-phone'),
    (0, swagger_1.ApiOperation)({ summary: 'Verify phone OTP after registration' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [verify_phone_dto_1.VerifyPhoneDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "verifyPhone", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('resend-otp'),
    (0, swagger_1.ApiOperation)({ summary: 'Resend registration OTP' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [resend_otp_dto_1.ResendOtpDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "resendOtp", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('login'),
    (0, swagger_1.ApiOperation)({ summary: 'Login employee or employer' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Headers)('user-agent')),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [login_dto_1.LoginDto, String, Object]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "login", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('refresh'),
    (0, swagger_1.ApiOperation)({ summary: 'Refresh access token' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Headers)('user-agent')),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [refresh_token_dto_1.RefreshTokenDto, String, Object]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "refresh", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Post)('logout'),
    (0, swagger_1.ApiOperation)({ summary: 'Logout and revoke refresh token' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "logout", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Get)('me'),
    (0, swagger_1.ApiOperation)({ summary: 'Get current authenticated user' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "me", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Post)('change-password'),
    (0, swagger_1.ApiOperation)({ summary: 'Change password' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, change_password_dto_1.ChangePasswordDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "changePassword", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('forgot-password'),
    (0, swagger_1.ApiOperation)({ summary: 'Request password reset OTP via phone' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [forgot_password_dto_1.ForgotPasswordDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "forgotPassword", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('reset-password'),
    (0, swagger_1.ApiOperation)({ summary: 'Reset password with phone OTP' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [reset_password_dto_1.ResetPasswordDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "resetPassword", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)('google'),
    (0, common_1.UseGuards)(google_oauth_config_guard_1.GoogleOAuthConfigGuard, google_auth_guard_1.GoogleAuthGuard),
    (0, swagger_1.ApiOperation)({ summary: 'Start Google OAuth (pass role query param)' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "googleAuth", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)('google/callback'),
    (0, common_1.UseGuards)(google_oauth_config_guard_1.GoogleOAuthConfigGuard, google_auth_guard_1.GoogleAuthGuard),
    (0, swagger_1.ApiOperation)({ summary: 'Google OAuth callback' }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Res)()),
    __param(2, (0, common_1.Headers)('user-agent')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object, String]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "googleCallback", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('bind-phone'),
    (0, swagger_1.ApiOperation)({ summary: 'Bind phone after Google OAuth registration' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [google_auth_dto_1.BindPhoneDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "bindPhone", null);
exports.AuthController = AuthController = __decorate([
    (0, swagger_1.ApiTags)('Auth'),
    (0, common_1.Controller)('auth'),
    __metadata("design:paramtypes", [auth_service_1.AuthService,
        google_auth_service_1.GoogleAuthService])
], AuthController);
//# sourceMappingURL=auth.controller.js.map
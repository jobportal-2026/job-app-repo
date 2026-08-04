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
exports.AdminAuthController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const public_decorator_1 = require("../../common/decorators/public.decorator");
const refresh_token_dto_1 = require("../../auth/dto/refresh-token.dto");
const admin_auth_service_1 = require("./admin-auth.service");
const current_admin_decorator_1 = require("./decorators/current-admin.decorator");
const admin_login_dto_1 = require("./dto/admin-login.dto");
let AdminAuthController = class AdminAuthController {
    adminAuthService;
    constructor(adminAuthService) {
        this.adminAuthService = adminAuthService;
    }
    login(dto, userAgent, req) {
        return this.adminAuthService.login(dto, userAgent, req?.ip);
    }
    refresh(dto, userAgent, req) {
        return this.adminAuthService.refresh(dto.refreshToken, userAgent, req?.ip);
    }
    logout(admin, body) {
        return this.adminAuthService.logout(admin.sub, body.refreshToken);
    }
    me(admin) {
        return this.adminAuthService.me(admin.sub);
    }
};
exports.AdminAuthController = AdminAuthController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('login'),
    (0, swagger_1.ApiOperation)({ summary: 'Admin login (isolated from user auth)' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Headers)('user-agent')),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [admin_login_dto_1.AdminLoginDto, String, Object]),
    __metadata("design:returntype", void 0)
], AdminAuthController.prototype, "login", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('refresh'),
    (0, swagger_1.ApiOperation)({ summary: 'Refresh admin access token' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Headers)('user-agent')),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [refresh_token_dto_1.RefreshTokenDto, String, Object]),
    __metadata("design:returntype", void 0)
], AdminAuthController.prototype, "refresh", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)('admin'),
    (0, common_1.Post)('logout'),
    (0, swagger_1.ApiOperation)({ summary: 'Admin logout' }),
    __param(0, (0, current_admin_decorator_1.CurrentAdmin)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], AdminAuthController.prototype, "logout", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)('admin'),
    (0, common_1.Get)('me'),
    (0, swagger_1.ApiOperation)({ summary: 'Get current admin' }),
    __param(0, (0, current_admin_decorator_1.CurrentAdmin)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], AdminAuthController.prototype, "me", null);
exports.AdminAuthController = AdminAuthController = __decorate([
    (0, swagger_1.ApiTags)('Admin Auth'),
    (0, common_1.Controller)('admin/auth'),
    __metadata("design:paramtypes", [admin_auth_service_1.AdminAuthService])
], AdminAuthController);
//# sourceMappingURL=admin-auth.controller.js.map
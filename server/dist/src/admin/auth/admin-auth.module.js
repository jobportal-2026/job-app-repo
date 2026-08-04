"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdminAuthModule = void 0;
const common_1 = require("@nestjs/common");
const core_1 = require("@nestjs/core");
const jwt_1 = require("@nestjs/jwt");
const passport_1 = require("@nestjs/passport");
const admin_auth_controller_1 = require("./admin-auth.controller");
const admin_auth_service_1 = require("./admin-auth.service");
const admin_jwt_auth_guard_1 = require("./guards/admin-jwt-auth.guard");
const admin_repository_1 = require("./repositories/admin.repository");
const admin_jwt_strategy_1 = require("./strategies/admin-jwt.strategy");
let AdminAuthModule = class AdminAuthModule {
};
exports.AdminAuthModule = AdminAuthModule;
exports.AdminAuthModule = AdminAuthModule = __decorate([
    (0, common_1.Module)({
        imports: [passport_1.PassportModule, jwt_1.JwtModule.register({})],
        controllers: [admin_auth_controller_1.AdminAuthController],
        providers: [
            admin_auth_service_1.AdminAuthService,
            admin_repository_1.AdminRepository,
            admin_jwt_strategy_1.AdminJwtStrategy,
            admin_jwt_auth_guard_1.AdminJwtAuthGuard,
            {
                provide: core_1.APP_GUARD,
                useClass: admin_jwt_auth_guard_1.AdminJwtAuthGuard,
            },
        ],
        exports: [admin_auth_service_1.AdminAuthService, admin_jwt_auth_guard_1.AdminJwtAuthGuard],
    })
], AdminAuthModule);
//# sourceMappingURL=admin-auth.module.js.map
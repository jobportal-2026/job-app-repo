"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const core_1 = require("@nestjs/core");
const throttler_1 = require("@nestjs/throttler");
const admin_module_1 = require("./admin/admin.module");
const auth_module_1 = require("./auth/auth.module");
const global_exception_filter_1 = require("./common/filters/global-exception.filter");
const jwt_auth_guard_1 = require("./common/guards/jwt-auth.guard");
const logging_interceptor_1 = require("./common/interceptors/logging.interceptor");
const transform_response_interceptor_1 = require("./common/interceptors/transform-response.interceptor");
const config_module_1 = require("./config/config.module");
const database_module_1 = require("./database/database.module");
const audit_module_1 = require("./shared/audit/audit.module");
const health_module_1 = require("./shared/health/health.module");
const mail_module_1 = require("./shared/mail/mail.module");
const sms_module_1 = require("./shared/sms/sms.module");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_module_1.AppConfigModule,
            database_module_1.DatabaseModule,
            mail_module_1.MailModule,
            sms_module_1.SmsModule,
            audit_module_1.AuditModule,
            health_module_1.HealthModule,
            throttler_1.ThrottlerModule.forRoot([
                {
                    ttl: 60000,
                    limit: 100,
                },
            ]),
            auth_module_1.AuthModule,
            admin_module_1.AdminModule,
        ],
        providers: [
            {
                provide: core_1.APP_FILTER,
                useClass: global_exception_filter_1.GlobalExceptionFilter,
            },
            {
                provide: core_1.APP_INTERCEPTOR,
                useClass: transform_response_interceptor_1.TransformResponseInterceptor,
            },
            {
                provide: core_1.APP_INTERCEPTOR,
                useClass: logging_interceptor_1.LoggingInterceptor,
            },
            {
                provide: core_1.APP_GUARD,
                useClass: throttler_1.ThrottlerGuard,
            },
            {
                provide: core_1.APP_GUARD,
                useClass: jwt_auth_guard_1.JwtAuthGuard,
            },
        ],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map
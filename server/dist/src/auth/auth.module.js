"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const jwt_1 = require("@nestjs/jwt");
const passport_1 = require("@nestjs/passport");
const auth_controller_1 = require("./auth.controller");
const auth_service_1 = require("./auth.service");
const google_oauth_config_guard_1 = require("./guards/google-oauth-config.guard");
const oauth_account_repository_1 = require("./repositories/oauth-account.repository");
const otp_repository_1 = require("./repositories/otp.repository");
const refresh_token_repository_1 = require("./repositories/refresh-token.repository");
const revoked_token_repository_1 = require("./repositories/revoked-token.repository");
const users_repository_1 = require("./repositories/users.repository");
const google_auth_service_1 = require("./services/google-auth.service");
const otp_service_1 = require("./services/otp.service");
const token_service_1 = require("./services/token.service");
const google_strategy_1 = require("./strategies/google.strategy");
const jwt_strategy_1 = require("./strategies/jwt.strategy");
function buildGoogleProviders() {
    return [
        {
            provide: google_strategy_1.GoogleStrategy,
            useFactory: (configService) => {
                const clientID = configService.get('GOOGLE_CLIENT_ID')?.trim();
                const clientSecret = configService
                    .get('GOOGLE_CLIENT_SECRET')
                    ?.trim();
                if (!clientID || !clientSecret) {
                    return null;
                }
                return new google_strategy_1.GoogleStrategy(configService);
            },
            inject: [config_1.ConfigService],
        },
    ];
}
let AuthModule = class AuthModule {
};
exports.AuthModule = AuthModule;
exports.AuthModule = AuthModule = __decorate([
    (0, common_1.Module)({
        imports: [passport_1.PassportModule.register({ defaultStrategy: 'jwt' }), jwt_1.JwtModule.register({})],
        controllers: [auth_controller_1.AuthController],
        providers: [
            auth_service_1.AuthService,
            otp_service_1.OtpService,
            token_service_1.TokenService,
            google_auth_service_1.GoogleAuthService,
            google_oauth_config_guard_1.GoogleOAuthConfigGuard,
            users_repository_1.UsersRepository,
            otp_repository_1.OtpRepository,
            revoked_token_repository_1.RevokedTokenRepository,
            refresh_token_repository_1.RefreshTokenRepository,
            oauth_account_repository_1.OAuthAccountRepository,
            jwt_strategy_1.JwtStrategy,
            ...buildGoogleProviders(),
        ],
        exports: [auth_service_1.AuthService, users_repository_1.UsersRepository],
    })
], AuthModule);
//# sourceMappingURL=auth.module.js.map
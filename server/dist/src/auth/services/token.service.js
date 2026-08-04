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
exports.TokenService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const jwt_1 = require("@nestjs/jwt");
const crypto_1 = require("crypto");
const hash_util_1 = require("../../common/utils/hash.util");
const jwt_util_1 = require("../../common/utils/jwt.util");
const refresh_token_repository_1 = require("../repositories/refresh-token.repository");
let TokenService = class TokenService {
    jwtService;
    configService;
    refreshTokenRepository;
    constructor(jwtService, configService, refreshTokenRepository) {
        this.jwtService = jwtService;
        this.configService = configService;
        this.refreshTokenRepository = refreshTokenRepository;
    }
    async issueUserTokens(params) {
        const jti = (0, crypto_1.randomUUID)();
        const accessToken = await this.jwtService.signAsync({
            sub: params.userId,
            phone: params.phone,
            email: params.email,
            role: params.role,
            jti,
            type: 'access',
        }, {
            secret: this.configService.get('JWT_SECRET'),
            expiresIn: (0, jwt_util_1.jwtExpiresIn)(this.configService.get('JWT_ACCESS_EXPIRES_IN'), '15m'),
        });
        const refreshJti = (0, crypto_1.randomUUID)();
        const refreshToken = await this.jwtService.signAsync({
            sub: params.userId,
            jti: refreshJti,
            type: 'refresh',
        }, {
            secret: this.configService.get('JWT_REFRESH_SECRET'),
            expiresIn: (0, jwt_util_1.jwtExpiresIn)(this.configService.get('JWT_REFRESH_EXPIRES_IN'), '7d'),
        });
        const refreshExpiresIn = this.configService.get('JWT_REFRESH_EXPIRES_IN') ?? '7d';
        const expiresAt = this.calculateExpiry(refreshExpiresIn);
        await this.refreshTokenRepository.create({
            tokenHash: await (0, hash_util_1.hashValue)(refreshToken),
            user: { connect: { id: params.userId } },
            userAgent: params.userAgent,
            ipAddress: params.ipAddress,
            expiresAt,
        });
        return { accessToken, refreshToken };
    }
    async issueAdminTokens(params) {
        const jti = (0, crypto_1.randomUUID)();
        const accessToken = await this.jwtService.signAsync({
            sub: params.adminId,
            email: params.email,
            permissions: params.permissions,
            jti,
            type: 'admin_access',
        }, {
            secret: this.configService.get('ADMIN_JWT_SECRET'),
            expiresIn: (0, jwt_util_1.jwtExpiresIn)(this.configService.get('JWT_ACCESS_EXPIRES_IN'), '15m'),
        });
        const refreshJti = (0, crypto_1.randomUUID)();
        const refreshToken = await this.jwtService.signAsync({
            sub: params.adminId,
            jti: refreshJti,
            type: 'admin_refresh',
        }, {
            secret: this.configService.get('ADMIN_JWT_REFRESH_SECRET'),
            expiresIn: (0, jwt_util_1.jwtExpiresIn)(this.configService.get('JWT_REFRESH_EXPIRES_IN'), '7d'),
        });
        return { accessToken, refreshToken, refreshJti };
    }
    calculateExpiry(duration) {
        const match = duration.match(/^(\d+)([smhd])$/);
        if (!match) {
            return new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
        }
        const value = Number(match[1]);
        const unit = match[2];
        const multipliers = {
            s: 1000,
            m: 60 * 1000,
            h: 60 * 60 * 1000,
            d: 24 * 60 * 60 * 1000,
        };
        return new Date(Date.now() + value * multipliers[unit]);
    }
};
exports.TokenService = TokenService;
exports.TokenService = TokenService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [jwt_1.JwtService,
        config_1.ConfigService,
        refresh_token_repository_1.RefreshTokenRepository])
], TokenService);
//# sourceMappingURL=token.service.js.map
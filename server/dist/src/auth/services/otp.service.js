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
exports.OtpService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const client_1 = require("@prisma/client");
const app_constants_1 = require("../../common/constants/app.constants");
const business_exception_1 = require("../../common/exceptions/business.exception");
const hash_util_1 = require("../../common/utils/hash.util");
const token_util_1 = require("../../common/utils/token.util");
const otp_repository_1 = require("../repositories/otp.repository");
const sms_service_1 = require("../../shared/sms/sms.service");
let OtpService = class OtpService {
    otpRepository;
    sms;
    configService;
    constructor(otpRepository, sms, configService) {
        this.otpRepository = otpRepository;
        this.sms = sms;
        this.configService = configService;
    }
    get ttlSeconds() {
        return this.configService.get('OTP_TTL_SECONDS') ?? 300;
    }
    expiresAt() {
        return new Date(Date.now() + this.ttlSeconds * 1000);
    }
    async sendRegistrationOtp(phone) {
        await this.enforceResendLimit(phone);
        const code = (0, token_util_1.generateOtp)();
        const hash = await (0, hash_util_1.hashValue)(code);
        await this.otpRepository.upsert({
            phone,
            purpose: client_1.OtpPurpose.REGISTRATION,
            codeHash: hash,
            expiresAt: this.expiresAt(),
        });
        await this.sms.sendOtp(phone, code);
    }
    async sendPasswordResetOtp(phone) {
        await this.enforceResendLimit(phone);
        const code = (0, token_util_1.generateOtp)();
        const hash = await (0, hash_util_1.hashValue)(code);
        await this.otpRepository.upsert({
            phone,
            purpose: client_1.OtpPurpose.PASSWORD_RESET,
            codeHash: hash,
            expiresAt: this.expiresAt(),
        });
        await this.sms.sendOtp(phone, code);
    }
    async verifyRegistrationOtp(phone, code) {
        await this.verifyOtp(phone, client_1.OtpPurpose.REGISTRATION, code);
    }
    async verifyPasswordResetOtp(phone, code) {
        await this.verifyOtp(phone, client_1.OtpPurpose.PASSWORD_RESET, code);
    }
    async verifyOtp(phone, purpose, code) {
        const stored = await this.otpRepository.findValid(phone, purpose);
        if (!stored) {
            throw new business_exception_1.BusinessException('OTP expired or not found', common_1.HttpStatus.BAD_REQUEST);
        }
        const valid = await (0, hash_util_1.verifyHash)(stored.codeHash, code);
        if (!valid) {
            throw new business_exception_1.BusinessException('Invalid OTP', common_1.HttpStatus.BAD_REQUEST);
        }
        await this.otpRepository.delete(phone, purpose);
    }
    async enforceResendLimit(phone) {
        const record = await this.otpRepository.incrementResendCount(phone, app_constants_1.OTP_RESEND_WINDOW_SECONDS);
        if (record.attempts > app_constants_1.OTP_RESEND_LIMIT) {
            throw new business_exception_1.BusinessException('OTP resend limit exceeded', common_1.HttpStatus.TOO_MANY_REQUESTS);
        }
    }
};
exports.OtpService = OtpService;
exports.OtpService = OtpService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [otp_repository_1.OtpRepository,
        sms_service_1.SmsService,
        config_1.ConfigService])
], OtpService);
//# sourceMappingURL=otp.service.js.map
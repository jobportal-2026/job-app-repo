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
exports.OtpRepository = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const prisma_service_1 = require("../../database/prisma.service");
let OtpRepository = class OtpRepository {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async upsert(params) {
        return this.prisma.otpVerification.upsert({
            where: {
                phone_purpose: { phone: params.phone, purpose: params.purpose },
            },
            create: {
                phone: params.phone,
                purpose: params.purpose,
                codeHash: params.codeHash,
                expiresAt: params.expiresAt,
            },
            update: {
                codeHash: params.codeHash,
                expiresAt: params.expiresAt,
                attempts: 0,
            },
        });
    }
    async findValid(phone, purpose) {
        const record = await this.prisma.otpVerification.findUnique({
            where: { phone_purpose: { phone, purpose } },
        });
        if (!record || record.expiresAt <= new Date()) {
            return null;
        }
        return record;
    }
    async delete(phone, purpose) {
        await this.prisma.otpVerification.deleteMany({
            where: { phone, purpose },
        });
    }
    async incrementResendCount(phone, windowSeconds) {
        const purpose = client_1.OtpPurpose.RESEND_LIMIT;
        const expiresAt = new Date(Date.now() + windowSeconds * 1000);
        const existing = await this.prisma.otpVerification.findUnique({
            where: { phone_purpose: { phone, purpose } },
        });
        if (!existing || existing.expiresAt <= new Date()) {
            return this.prisma.otpVerification.upsert({
                where: { phone_purpose: { phone, purpose } },
                create: {
                    phone,
                    purpose,
                    codeHash: '0',
                    attempts: 1,
                    expiresAt,
                },
                update: { attempts: 1, expiresAt, codeHash: '0' },
            });
        }
        return this.prisma.otpVerification.update({
            where: { phone_purpose: { phone, purpose } },
            data: { attempts: { increment: 1 } },
        });
    }
};
exports.OtpRepository = OtpRepository;
exports.OtpRepository = OtpRepository = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], OtpRepository);
//# sourceMappingURL=otp.repository.js.map
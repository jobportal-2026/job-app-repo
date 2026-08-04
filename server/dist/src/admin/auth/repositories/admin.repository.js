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
exports.AdminRepository = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../../database/prisma.service");
let AdminRepository = class AdminRepository {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    findByEmail(email) {
        return this.prisma.admin.findUnique({ where: { email } });
    }
    findById(id) {
        return this.prisma.admin.findUnique({ where: { id } });
    }
    createRefreshToken(data) {
        return this.prisma.adminRefreshToken.create({ data });
    }
    findActiveRefreshTokens(adminId) {
        return this.prisma.adminRefreshToken.findMany({
            where: {
                adminId,
                revokedAt: null,
                expiresAt: { gt: new Date() },
            },
        });
    }
    revokeRefreshToken(id) {
        return this.prisma.adminRefreshToken.update({
            where: { id },
            data: { revokedAt: new Date() },
        });
    }
    revokeAllRefreshTokens(adminId) {
        return this.prisma.adminRefreshToken.updateMany({
            where: { adminId, revokedAt: null },
            data: { revokedAt: new Date() },
        });
    }
    updateLastLogin(id) {
        return this.prisma.admin.update({
            where: { id },
            data: { lastLoginAt: new Date() },
        });
    }
};
exports.AdminRepository = AdminRepository;
exports.AdminRepository = AdminRepository = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], AdminRepository);
//# sourceMappingURL=admin.repository.js.map
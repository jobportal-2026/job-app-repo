import { Prisma } from '@prisma/client';
import { PrismaService } from '../../../database/prisma.service';
export declare class AdminRepository {
    private readonly prisma;
    constructor(prisma: PrismaService);
    findByEmail(email: string): Prisma.Prisma__AdminClient<{
        id: string;
        email: string;
        passwordHash: string;
        name: string;
        isActive: boolean;
        permissions: string[];
        lastLoginAt: Date | null;
        createdAt: Date;
        updatedAt: Date;
    } | null, null, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
    findById(id: string): Prisma.Prisma__AdminClient<{
        id: string;
        email: string;
        passwordHash: string;
        name: string;
        isActive: boolean;
        permissions: string[];
        lastLoginAt: Date | null;
        createdAt: Date;
        updatedAt: Date;
    } | null, null, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
    createRefreshToken(data: Prisma.AdminRefreshTokenCreateInput): Prisma.Prisma__AdminRefreshTokenClient<{
        id: string;
        createdAt: Date;
        ipAddress: string | null;
        userAgent: string | null;
        adminId: string;
        tokenHash: string;
        expiresAt: Date;
        revokedAt: Date | null;
    }, never, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
    findActiveRefreshTokens(adminId: string): Prisma.PrismaPromise<{
        id: string;
        createdAt: Date;
        ipAddress: string | null;
        userAgent: string | null;
        adminId: string;
        tokenHash: string;
        expiresAt: Date;
        revokedAt: Date | null;
    }[]>;
    revokeRefreshToken(id: string): Prisma.Prisma__AdminRefreshTokenClient<{
        id: string;
        createdAt: Date;
        ipAddress: string | null;
        userAgent: string | null;
        adminId: string;
        tokenHash: string;
        expiresAt: Date;
        revokedAt: Date | null;
    }, never, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
    revokeAllRefreshTokens(adminId: string): Prisma.PrismaPromise<Prisma.BatchPayload>;
    updateLastLogin(id: string): Prisma.Prisma__AdminClient<{
        id: string;
        email: string;
        passwordHash: string;
        name: string;
        isActive: boolean;
        permissions: string[];
        lastLoginAt: Date | null;
        createdAt: Date;
        updatedAt: Date;
    }, never, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
}

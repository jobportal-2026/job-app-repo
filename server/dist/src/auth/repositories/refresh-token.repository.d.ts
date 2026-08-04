import { Prisma } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
export declare class RefreshTokenRepository {
    private readonly prisma;
    constructor(prisma: PrismaService);
    create(data: Prisma.RefreshTokenCreateInput): Prisma.Prisma__RefreshTokenClient<{
        id: string;
        createdAt: Date;
        ipAddress: string | null;
        userAgent: string | null;
        userId: string;
        tokenHash: string;
        expiresAt: Date;
        revokedAt: Date | null;
    }, never, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
    findActiveByUserId(userId: string): Prisma.PrismaPromise<{
        id: string;
        createdAt: Date;
        ipAddress: string | null;
        userAgent: string | null;
        userId: string;
        tokenHash: string;
        expiresAt: Date;
        revokedAt: Date | null;
    }[]>;
    findById(id: string): Prisma.Prisma__RefreshTokenClient<{
        id: string;
        createdAt: Date;
        ipAddress: string | null;
        userAgent: string | null;
        userId: string;
        tokenHash: string;
        expiresAt: Date;
        revokedAt: Date | null;
    } | null, null, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
    revoke(id: string): Prisma.Prisma__RefreshTokenClient<{
        id: string;
        createdAt: Date;
        ipAddress: string | null;
        userAgent: string | null;
        userId: string;
        tokenHash: string;
        expiresAt: Date;
        revokedAt: Date | null;
    }, never, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
    revokeAllForUser(userId: string): Prisma.PrismaPromise<Prisma.BatchPayload>;
}

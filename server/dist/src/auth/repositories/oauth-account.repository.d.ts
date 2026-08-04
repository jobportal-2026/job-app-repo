import { AuthProvider, Prisma } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
export declare class OAuthAccountRepository {
    private readonly prisma;
    constructor(prisma: PrismaService);
    findByProvider(provider: AuthProvider, providerUserId: string): Prisma.Prisma__OAuthAccountClient<({
        user: {
            id: string;
            email: string | null;
            passwordHash: string | null;
            name: string;
            lastLoginAt: Date | null;
            createdAt: Date;
            updatedAt: Date;
            phone: string;
            role: import("@prisma/client").$Enums.UserRole;
            status: import("@prisma/client").$Enums.UserStatus;
            phoneVerified: boolean;
            phoneVerifiedAt: Date | null;
            deletedAt: Date | null;
        };
    } & {
        id: string;
        createdAt: Date;
        userId: string;
        provider: import("@prisma/client").$Enums.AuthProvider;
        providerUserId: string;
    }) | null, null, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
    create(data: Prisma.OAuthAccountCreateInput): Prisma.Prisma__OAuthAccountClient<{
        id: string;
        createdAt: Date;
        userId: string;
        provider: import("@prisma/client").$Enums.AuthProvider;
        providerUserId: string;
    }, never, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
}

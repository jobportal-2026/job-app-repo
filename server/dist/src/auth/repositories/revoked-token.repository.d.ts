import { PrismaService } from '../../database/prisma.service';
export declare class RevokedTokenRepository {
    private readonly prisma;
    constructor(prisma: PrismaService);
    isRevoked(jti: string): Promise<boolean>;
    revoke(jti: string, expiresAt: Date): Promise<void>;
}

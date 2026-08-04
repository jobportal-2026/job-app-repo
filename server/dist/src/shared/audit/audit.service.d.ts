import { AuditAction, Prisma } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
export declare class AuditService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    log(params: {
        action: AuditAction;
        entityType: string;
        entityId?: string;
        userId?: string;
        adminId?: string;
        ipAddress?: string;
        userAgent?: string;
        metadata?: Prisma.InputJsonValue;
    }): Promise<void>;
}

import { OtpPurpose } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
export declare class OtpRepository {
    private readonly prisma;
    constructor(prisma: PrismaService);
    upsert(params: {
        phone: string;
        purpose: OtpPurpose;
        codeHash: string;
        expiresAt: Date;
    }): Promise<{
        id: string;
        createdAt: Date;
        expiresAt: Date;
        phone: string;
        purpose: import("@prisma/client").$Enums.OtpPurpose;
        codeHash: string;
        attempts: number;
    }>;
    findValid(phone: string, purpose: OtpPurpose): Promise<{
        id: string;
        createdAt: Date;
        expiresAt: Date;
        phone: string;
        purpose: import("@prisma/client").$Enums.OtpPurpose;
        codeHash: string;
        attempts: number;
    } | null>;
    delete(phone: string, purpose: OtpPurpose): Promise<void>;
    incrementResendCount(phone: string, windowSeconds: number): Promise<{
        id: string;
        createdAt: Date;
        expiresAt: Date;
        phone: string;
        purpose: import("@prisma/client").$Enums.OtpPurpose;
        codeHash: string;
        attempts: number;
    }>;
}

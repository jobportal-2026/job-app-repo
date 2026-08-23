import { Injectable } from '@nestjs/common';
import { OtpPurpose } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';

@Injectable()
export class OtpRepository {
  constructor(private readonly prisma: PrismaService) {}

  async upsert(params: {
    phone: string;
    purpose: OtpPurpose;
    codeHash: string;
    expiresAt: Date;
  }) {
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

  async findValid(phone: string, purpose: OtpPurpose) {
    const record = await this.prisma.otpVerification.findUnique({
      where: { phone_purpose: { phone, purpose } },
    });

    if (!record || record.expiresAt <= new Date()) {
      return null;
    }

    return record;
  }

  async delete(phone: string, purpose: OtpPurpose) {
    await this.prisma.otpVerification.deleteMany({
      where: { phone, purpose },
    });
  }

  async incrementResendCount(phone: string, windowSeconds: number) {
    const purpose = OtpPurpose.RESEND_LIMIT;
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
}

import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';

@Injectable()
export class RevokedTokenRepository {
  constructor(private readonly prisma: PrismaService) {}

  async isRevoked(jti: string): Promise<boolean> {
    const record = await this.prisma.revokedToken.findUnique({
      where: { jti },
    });

    if (!record) {
      return false;
    }

    if (record.expiresAt <= new Date()) {
      await this.prisma.revokedToken.delete({ where: { jti } });
      return false;
    }

    return true;
  }

  async revoke(jti: string, expiresAt: Date) {
    await this.prisma.revokedToken.upsert({
      where: { jti },
      create: { jti, expiresAt },
      update: { expiresAt },
    });
  }
}

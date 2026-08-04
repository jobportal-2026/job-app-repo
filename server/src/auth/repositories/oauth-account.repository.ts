import { Injectable } from '@nestjs/common';
import { AuthProvider, Prisma } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';

@Injectable()
export class OAuthAccountRepository {
  constructor(private readonly prisma: PrismaService) {}

  findByProvider(provider: AuthProvider, providerUserId: string) {
    return this.prisma.oAuthAccount.findUnique({
      where: {
        provider_providerUserId: { provider, providerUserId },
      },
      include: { user: true },
    });
  }

  create(data: Prisma.OAuthAccountCreateInput) {
    return this.prisma.oAuthAccount.create({ data });
  }
}

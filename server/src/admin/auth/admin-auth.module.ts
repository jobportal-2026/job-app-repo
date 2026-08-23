import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AdminAuthController } from './admin-auth.controller';
import { AdminAuthService } from './admin-auth.service';
import { AdminJwtAuthGuard } from './guards/admin-jwt-auth.guard';
import { AdminRepository } from './repositories/admin.repository';
import { AdminJwtStrategy } from './strategies/admin-jwt.strategy';

@Module({
  imports: [PassportModule, JwtModule.register({})],
  controllers: [AdminAuthController],
  providers: [
    AdminAuthService,
    AdminRepository,
    AdminJwtStrategy,
    AdminJwtAuthGuard,
    {
      provide: APP_GUARD,
      useClass: AdminJwtAuthGuard,
    },
  ],
  exports: [AdminAuthService, AdminJwtAuthGuard],
})
export class AdminAuthModule {}

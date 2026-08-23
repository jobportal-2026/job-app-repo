import { Module, Provider } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { GoogleOAuthConfigGuard } from './guards/google-oauth-config.guard';
import { OAuthAccountRepository } from './repositories/oauth-account.repository';
import { OtpRepository } from './repositories/otp.repository';
import { RefreshTokenRepository } from './repositories/refresh-token.repository';
import { RevokedTokenRepository } from './repositories/revoked-token.repository';
import { UsersRepository } from './repositories/users.repository';
import { GoogleAuthService } from './services/google-auth.service';
import { OtpService } from './services/otp.service';
import { TokenService } from './services/token.service';
import { GoogleStrategy } from './strategies/google.strategy';
import { JwtStrategy } from './strategies/jwt.strategy';

function buildGoogleProviders(): Provider[] {
  return [
    {
      provide: GoogleStrategy,
      useFactory: (configService: ConfigService) => {
        const clientID = configService.get<string>('GOOGLE_CLIENT_ID')?.trim();
        const clientSecret = configService
          .get<string>('GOOGLE_CLIENT_SECRET')
          ?.trim();

        if (!clientID || !clientSecret) {
          return null;
        }

        return new GoogleStrategy(configService);
      },
      inject: [ConfigService],
    },
  ];
}

@Module({
  imports: [PassportModule.register({ defaultStrategy: 'jwt' }), JwtModule.register({})],
  controllers: [AuthController],
  providers: [
    AuthService,
    OtpService,
    TokenService,
    GoogleAuthService,
    GoogleOAuthConfigGuard,
    UsersRepository,
    OtpRepository,
    RevokedTokenRepository,
    RefreshTokenRepository,
    OAuthAccountRepository,
    JwtStrategy,
    ...buildGoogleProviders(),
  ],
  exports: [AuthService, UsersRepository],
})
export class AuthModule {}

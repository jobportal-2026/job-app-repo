import {
  Body,
  Controller,
  Get,
  Headers,
  Post,
  Req,
  Res,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import type { Request, Response } from 'express';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import type { JwtPayload } from '../common/interfaces/jwt-payload.interface';
import { AuthService } from './auth.service';
import { ChangePasswordDto } from './dto/change-password.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { RegisterDto } from './dto/register.dto';
import { ResendOtpDto } from './dto/resend-otp.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { VerifyPhoneDto } from './dto/verify-phone.dto';
import { GoogleAuthGuard } from './guards/google-auth.guard';
import { GoogleOAuthConfigGuard } from './guards/google-oauth-config.guard';
import { GoogleAuthService } from './services/google-auth.service';
import { BindPhoneDto } from './dto/google-auth.dto';
import { AppRole } from '../common/constants/roles.enum';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly googleAuthService: GoogleAuthService,
  ) {}

  @Public()
  @Post('register')
  @ApiOperation({ summary: 'Register employee or employer' })
  register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Public()
  @Post('verify-phone')
  @ApiOperation({ summary: 'Verify phone OTP after registration' })
  verifyPhone(@Body() dto: VerifyPhoneDto) {
    return this.authService.verifyPhone(dto.phone, dto.code);
  }

  @Public()
  @Post('resend-otp')
  @ApiOperation({ summary: 'Resend registration OTP' })
  resendOtp(@Body() dto: ResendOtpDto) {
    return this.authService.resendOtp(dto.phone);
  }

  @Public()
  @Post('login')
  @ApiOperation({ summary: 'Login employee or employer' })
  login(
    @Body() dto: LoginDto,
    @Headers('user-agent') userAgent?: string,
    @Req() req?: Request,
  ) {
    return this.authService.login(dto, userAgent, req?.ip);
  }

  @Public()
  @Post('refresh')
  @ApiOperation({ summary: 'Refresh access token' })
  refresh(
    @Body() dto: RefreshTokenDto,
    @Headers('user-agent') userAgent?: string,
    @Req() req?: Request,
  ) {
    return this.authService.refresh(dto.refreshToken, userAgent, req?.ip);
  }

  @ApiBearerAuth()
  @Post('logout')
  @ApiOperation({ summary: 'Logout and revoke refresh token' })
  logout(
    @CurrentUser() user: JwtPayload,
    @Body() body: Partial<RefreshTokenDto>,
  ) {
    return this.authService.logout(
      user.sub,
      user.jti,
      user.exp,
      body.refreshToken,
    );
  }

  @ApiBearerAuth()
  @Get('me')
  @ApiOperation({ summary: 'Get current authenticated user' })
  me(@CurrentUser() user: JwtPayload) {
    return this.authService.getCurrentUser(user.sub);
  }

  @ApiBearerAuth()
  @Post('change-password')
  @ApiOperation({ summary: 'Change password' })
  changePassword(
    @CurrentUser() user: JwtPayload,
    @Body() dto: ChangePasswordDto,
  ) {
    return this.authService.changePassword(user.sub, dto);
  }

  @Public()
  @Post('forgot-password')
  @ApiOperation({ summary: 'Request password reset OTP via phone' })
  forgotPassword(@Body() dto: ForgotPasswordDto) {
    return this.authService.forgotPassword(dto);
  }

  @Public()
  @Post('reset-password')
  @ApiOperation({ summary: 'Reset password with phone OTP' })
  resetPassword(@Body() dto: ResetPasswordDto) {
    return this.authService.resetPassword(dto);
  }

  @Public()
  @Get('google')
  @UseGuards(GoogleOAuthConfigGuard, GoogleAuthGuard)
  @ApiOperation({ summary: 'Start Google OAuth (pass role query param)' })
  googleAuth() {
    return;
  }

  @Public()
  @Get('google/callback')
  @UseGuards(GoogleOAuthConfigGuard, GoogleAuthGuard)
  @ApiOperation({ summary: 'Google OAuth callback' })
  async googleCallback(
    @Req() req: Request,
    @Res() res: Response,
    @Headers('user-agent') userAgent?: string,
  ) {
    const result = await this.googleAuthService.handleCallback(
      req.user as unknown as {
        providerUserId: string;
        email?: string;
        name: string;
        role: AppRole;
      },
      userAgent,
      req.ip,
    );

    return res.json({
      success: true,
      message: '',
      data: result,
    });
  }

  @Public()
  @Post('bind-phone')
  @ApiOperation({ summary: 'Bind phone after Google OAuth registration' })
  bindPhone(@Body() dto: BindPhoneDto) {
    return this.googleAuthService.bindPhone(dto.userId, dto.phone, dto.code);
  }
}

import { Body, Controller, Get, Headers, Post, Req } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import type { Request } from 'express';
import { Public } from '../../common/decorators/public.decorator';
import { RefreshTokenDto } from '../../auth/dto/refresh-token.dto';
import { AdminAuthService } from './admin-auth.service';
import { CurrentAdmin } from './decorators/current-admin.decorator';
import { AdminLoginDto } from './dto/admin-login.dto';
import type { AdminJwtPayload } from '../../common/interfaces/jwt-payload.interface';

@ApiTags('Admin Auth')
@Controller('admin/auth')
export class AdminAuthController {
  constructor(private readonly adminAuthService: AdminAuthService) {}

  @Public()
  @Post('login')
  @ApiOperation({ summary: 'Admin login (isolated from user auth)' })
  login(
    @Body() dto: AdminLoginDto,
    @Headers('user-agent') userAgent?: string,
    @Req() req?: Request,
  ) {
    return this.adminAuthService.login(dto, userAgent, req?.ip);
  }

  @Public()
  @Post('refresh')
  @ApiOperation({ summary: 'Refresh admin access token' })
  refresh(
    @Body() dto: RefreshTokenDto,
    @Headers('user-agent') userAgent?: string,
    @Req() req?: Request,
  ) {
    return this.adminAuthService.refresh(dto.refreshToken, userAgent, req?.ip);
  }

  @ApiBearerAuth('admin')
  @Post('logout')
  @ApiOperation({ summary: 'Admin logout' })
  logout(
    @CurrentAdmin() admin: AdminJwtPayload,
    @Body() body: Partial<RefreshTokenDto>,
  ) {
    return this.adminAuthService.logout(admin.sub, body.refreshToken);
  }

  @ApiBearerAuth('admin')
  @Get('me')
  @ApiOperation({ summary: 'Get current admin' })
  me(@CurrentAdmin() admin: AdminJwtPayload) {
    return this.adminAuthService.me(admin.sub);
  }
}

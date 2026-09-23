import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsOptional, IsString, Matches } from 'class-validator';
import { AppRole } from '../../common/constants/roles.enum';

export class GoogleAuthQueryDto {
  @ApiProperty({ enum: AppRole })
  @IsEnum(AppRole)
  role!: AppRole;
}

export class BindPhoneDto {
  @ApiProperty()
  @IsString()
  userId!: string;

  @ApiProperty({ example: '+14155552671' })
  @IsString()
  @Matches(/^\+[1-9]\d{6,14}$/)
  phone!: string;

  @ApiPropertyOptional({ example: '123456' })
  @IsOptional()
  @IsString()
  code?: string;
}

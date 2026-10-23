import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, Matches } from 'class-validator';

export class VerifyPhoneDto {
  @ApiProperty({ example: '+14155552671' })
  @IsString()
  @Matches(/^\+[1-9]\d{6,14}$/)
  phone!: string;

  @ApiProperty({ example: '123456', required: false })
  @IsString()
  @IsOptional()
  code?: string;

  @ApiProperty({ example: 'firebase-id-token...', required: false })
  @IsString()
  @IsOptional()
  firebaseToken?: string;
}


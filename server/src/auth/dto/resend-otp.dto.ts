import { ApiProperty } from '@nestjs/swagger';
import { IsString, Matches } from 'class-validator';

export class ResendOtpDto {
  @ApiProperty({ example: '+14155552671' })
  @IsString()
  @Matches(/^\+[1-9]\d{6,14}$/)
  phone!: string;
}

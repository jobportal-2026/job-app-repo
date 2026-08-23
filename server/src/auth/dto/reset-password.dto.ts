import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, Matches, MinLength } from 'class-validator';

export class ResetPasswordDto {
  @ApiProperty({ example: '+14155552671' })
  @IsString()
  @Matches(/^\+[1-9]\d{6,14}$/)
  phone!: string;

  @ApiProperty({ example: '123456' })
  @IsString()
  @IsNotEmpty()
  code!: string;

  @ApiProperty({ minLength: 8 })
  @IsString()
  @MinLength(8)
  newPassword!: string;
}

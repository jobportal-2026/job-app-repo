import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsString, MinLength } from 'class-validator';
import { AppRole } from '../../common/constants/roles.enum';

export class LoginDto {
  @ApiProperty({ example: 'jane@example.com' })
  @IsString()
  @IsNotEmpty()
  email!: string;

  @ApiProperty()
  @IsString()
  @MinLength(8)
  password!: string;

  @ApiProperty({ enum: AppRole })
  @IsEnum(AppRole)
  role!: AppRole;
}

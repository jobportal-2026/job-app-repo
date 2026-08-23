import { ApiProperty } from '@nestjs/swagger';
import { AppRole } from '../../common/constants/roles.enum';

export class AuthUserResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  name!: string;

  @ApiProperty({ required: false })
  email?: string | null;

  @ApiProperty()
  phone!: string;

  @ApiProperty({ enum: AppRole })
  role!: AppRole;

  @ApiProperty()
  phoneVerified!: boolean;

  @ApiProperty()
  status!: string;
}

export class AuthTokensResponseDto {
  @ApiProperty()
  accessToken!: string;

  @ApiProperty()
  refreshToken!: string;

  @ApiProperty({ type: AuthUserResponseDto })
  user!: AuthUserResponseDto;
}

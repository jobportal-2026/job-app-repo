import { AppRole } from '../../common/constants/roles.enum';
export declare class AuthUserResponseDto {
    id: string;
    name: string;
    email?: string | null;
    phone: string;
    role: AppRole;
    phoneVerified: boolean;
    status: string;
}
export declare class AuthTokensResponseDto {
    accessToken: string;
    refreshToken: string;
    user: AuthUserResponseDto;
}

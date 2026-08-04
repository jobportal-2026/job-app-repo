import { AppRole } from '../../common/constants/roles.enum';
export declare class GoogleAuthQueryDto {
    role: AppRole;
}
export declare class BindPhoneDto {
    userId: string;
    phone: string;
    code?: string;
}

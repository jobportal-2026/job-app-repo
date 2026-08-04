import { AppRole } from '../../common/constants/roles.enum';
export declare class RegisterDto {
    name: string;
    email?: string;
    phone: string;
    password: string;
    role: AppRole;
}

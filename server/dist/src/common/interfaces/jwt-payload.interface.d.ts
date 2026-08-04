import { AppRole } from '../constants/roles.enum';
export interface JwtPayload {
    sub: string;
    email?: string | null;
    phone: string;
    role: AppRole;
    jti: string;
    type: 'access';
    exp?: number;
}
export interface AdminJwtPayload {
    sub: string;
    email: string;
    permissions: string[];
    jti: string;
    type: 'admin_access';
}
export interface RefreshJwtPayload {
    sub: string;
    jti: string;
    type: 'refresh';
}
export interface AdminRefreshJwtPayload {
    sub: string;
    jti: string;
    type: 'admin_refresh';
}
declare module 'express' {
    interface Request {
        user?: JwtPayload | AdminJwtPayload;
    }
}

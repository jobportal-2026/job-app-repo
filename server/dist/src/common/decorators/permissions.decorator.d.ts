import { AdminPermission } from '../constants/roles.enum';
export declare const PERMISSIONS_KEY = "permissions";
export declare const Permissions: (...permissions: AdminPermission[]) => import("@nestjs/common").CustomDecorator<string>;

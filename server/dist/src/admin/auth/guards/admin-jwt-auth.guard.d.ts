import { ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
declare const AdminJwtAuthGuard_base: import("@nestjs/passport").Type<import("@nestjs/passport").IAuthGuard>;
export declare class AdminJwtAuthGuard extends AdminJwtAuthGuard_base {
    private readonly reflector;
    constructor(reflector: Reflector);
    canActivate(context: ExecutionContext): boolean | Promise<boolean> | import("rxjs").Observable<boolean>;
    handleRequest<T>(err: Error | null, user: T): T;
}
export {};

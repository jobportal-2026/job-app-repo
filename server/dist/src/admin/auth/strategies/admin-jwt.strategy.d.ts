import { ConfigService } from '@nestjs/config';
import { Strategy } from 'passport-jwt';
import { AdminJwtPayload } from '../../../common/interfaces/jwt-payload.interface';
declare const AdminJwtStrategy_base: new (...args: [opt: import("passport-jwt").StrategyOptionsWithRequest] | [opt: import("passport-jwt").StrategyOptionsWithoutRequest]) => Strategy & {
    validate(...args: any[]): unknown;
};
export declare class AdminJwtStrategy extends AdminJwtStrategy_base {
    constructor(configService: ConfigService);
    validate(payload: AdminJwtPayload): AdminJwtPayload;
}
export {};

import { ConfigService } from '@nestjs/config';
import { Strategy } from 'passport-jwt';
import { JwtPayload } from '../../common/interfaces/jwt-payload.interface';
import { RevokedTokenRepository } from '../repositories/revoked-token.repository';
declare const JwtStrategy_base: new (...args: [opt: import("passport-jwt").StrategyOptionsWithRequest] | [opt: import("passport-jwt").StrategyOptionsWithoutRequest]) => Strategy & {
    validate(...args: any[]): unknown;
};
export declare class JwtStrategy extends JwtStrategy_base {
    private readonly revokedTokenRepository;
    constructor(configService: ConfigService, revokedTokenRepository: RevokedTokenRepository);
    validate(payload: JwtPayload): Promise<JwtPayload>;
}
export {};

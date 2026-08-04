import { ConfigService } from '@nestjs/config';
import { Strategy, VerifyCallback } from 'passport-google-oauth20';
export interface GoogleProfile {
    id: string;
    emails: Array<{
        value: string;
        verified?: boolean;
    }>;
    displayName: string;
}
declare const GoogleStrategy_base: new (...args: [options: import("passport-google-oauth20").StrategyOptionsWithRequest] | [options: import("passport-google-oauth20").StrategyOptions] | [options: import("passport-google-oauth20").StrategyOptions] | [options: import("passport-google-oauth20").StrategyOptionsWithRequest]) => Strategy & {
    validate(...args: any[]): unknown;
};
export declare class GoogleStrategy extends GoogleStrategy_base {
    constructor(configService: ConfigService);
    validate(req: {
        query: {
            state?: string;
        };
    }, _accessToken: string, _refreshToken: string, profile: GoogleProfile, done: VerifyCallback): void;
}
export {};

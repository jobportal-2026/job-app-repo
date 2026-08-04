declare enum Environment {
    Development = "development",
    Production = "production",
    Test = "test"
}
export declare class EnvironmentVariables {
    NODE_ENV: Environment;
    PORT: number;
    DATABASE_URL: string;
    JWT_SECRET: string;
    JWT_REFRESH_SECRET: string;
    ADMIN_JWT_SECRET: string;
    ADMIN_JWT_REFRESH_SECRET: string;
    JWT_ACCESS_EXPIRES_IN?: string;
    JWT_REFRESH_EXPIRES_IN?: string;
    CORS_ORIGINS?: string;
    GOOGLE_CLIENT_ID?: string;
    GOOGLE_CLIENT_SECRET?: string;
    GOOGLE_CALLBACK_URL?: string;
    TWILIO_ACCOUNT_SID?: string;
    TWILIO_AUTH_TOKEN?: string;
    TWILIO_PHONE_NUMBER?: string;
    SMTP_HOST?: string;
    SMTP_PORT?: number;
    SMTP_USER?: string;
    SMTP_PASS?: string;
    SMTP_FROM?: string;
    OTP_TTL_SECONDS?: number;
    OTP_MAX_ATTEMPTS?: number;
}
export declare function validate(config: Record<string, unknown>): EnvironmentVariables;
export {};

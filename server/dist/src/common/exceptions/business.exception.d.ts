import { HttpException, HttpStatus } from '@nestjs/common';
export declare class BusinessException extends HttpException {
    readonly errors: Array<{
        field?: string;
        message: string;
    }>;
    constructor(message: string, status?: HttpStatus, errors?: Array<{
        field?: string;
        message: string;
    }>);
}

import { HttpException, HttpStatus } from '@nestjs/common';

export class BusinessException extends HttpException {
  constructor(
    message: string,
    status: HttpStatus = HttpStatus.BAD_REQUEST,
    public readonly errors: Array<{ field?: string; message: string }> = [],
  ) {
    super(message, status);
  }
}

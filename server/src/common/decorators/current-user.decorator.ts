import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { Request } from 'express';
import { JwtPayload } from '../interfaces/jwt-payload.interface';

export const CurrentUser = createParamDecorator(
  (data: string | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest<Request>();
    const user = request.user as JwtPayload | undefined;
    if (!user) return undefined;
    if (data === 'id' || data === 'sub' || data === 'userId') {
      return user.sub;
    }
    if (data && typeof user === 'object' && data in user) {
      return (user as unknown as Record<string, unknown>)[data];
    }
    return user;
  },
);


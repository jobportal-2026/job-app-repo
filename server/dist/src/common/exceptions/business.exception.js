"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.BusinessException = void 0;
const common_1 = require("@nestjs/common");
class BusinessException extends common_1.HttpException {
    errors;
    constructor(message, status = common_1.HttpStatus.BAD_REQUEST, errors = []) {
        super(message, status);
        this.errors = errors;
    }
}
exports.BusinessException = BusinessException;
//# sourceMappingURL=business.exception.js.map
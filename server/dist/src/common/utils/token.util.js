"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateOtp = generateOtp;
exports.generateSecureToken = generateSecureToken;
const crypto_1 = require("crypto");
const app_constants_1 = require("../constants/app.constants");
function generateOtp() {
    const min = 10 ** (app_constants_1.OTP_LENGTH - 1);
    const max = 10 ** app_constants_1.OTP_LENGTH - 1;
    return String((0, crypto_1.randomInt)(min, max + 1));
}
function generateSecureToken() {
    return crypto.randomUUID().replace(/-/g, '');
}
//# sourceMappingURL=token.util.js.map
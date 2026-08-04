"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.sanitizeText = sanitizeText;
exports.normalizePhone = normalizePhone;
const sanitize_html_1 = __importDefault(require("sanitize-html"));
function sanitizeText(value) {
    return (0, sanitize_html_1.default)(value, {
        allowedTags: [],
        allowedAttributes: {},
    }).trim();
}
function normalizePhone(phone) {
    const cleaned = phone.replace(/[^\d+]/g, '');
    if (!cleaned.startsWith('+')) {
        throw new Error('Phone must be in E.164 format');
    }
    return cleaned;
}
//# sourceMappingURL=sanitize.util.js.map
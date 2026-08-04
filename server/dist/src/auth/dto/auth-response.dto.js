"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthTokensResponseDto = exports.AuthUserResponseDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const roles_enum_1 = require("../../common/constants/roles.enum");
class AuthUserResponseDto {
    id;
    name;
    email;
    phone;
    role;
    phoneVerified;
    status;
}
exports.AuthUserResponseDto = AuthUserResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], AuthUserResponseDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], AuthUserResponseDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ required: false }),
    __metadata("design:type", Object)
], AuthUserResponseDto.prototype, "email", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], AuthUserResponseDto.prototype, "phone", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ enum: roles_enum_1.AppRole }),
    __metadata("design:type", String)
], AuthUserResponseDto.prototype, "role", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Boolean)
], AuthUserResponseDto.prototype, "phoneVerified", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], AuthUserResponseDto.prototype, "status", void 0);
class AuthTokensResponseDto {
    accessToken;
    refreshToken;
    user;
}
exports.AuthTokensResponseDto = AuthTokensResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], AuthTokensResponseDto.prototype, "accessToken", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], AuthTokensResponseDto.prototype, "refreshToken", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ type: AuthUserResponseDto }),
    __metadata("design:type", AuthUserResponseDto)
], AuthTokensResponseDto.prototype, "user", void 0);
//# sourceMappingURL=auth-response.dto.js.map
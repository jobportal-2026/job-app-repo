"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdminPermission = exports.AppRole = void 0;
var AppRole;
(function (AppRole) {
    AppRole["EMPLOYEE"] = "employee";
    AppRole["EMPLOYER"] = "employer";
})(AppRole || (exports.AppRole = AppRole = {}));
var AdminPermission;
(function (AdminPermission) {
    AdminPermission["USERS_READ"] = "users:read";
    AdminPermission["USERS_WRITE"] = "users:write";
    AdminPermission["JOBS_MODERATE"] = "jobs:moderate";
    AdminPermission["REPORTS_MANAGE"] = "reports:manage";
    AdminPermission["ANALYTICS_READ"] = "analytics:read";
    AdminPermission["SYSTEM_CONFIG"] = "system:config";
})(AdminPermission || (exports.AdminPermission = AdminPermission = {}));
//# sourceMappingURL=roles.enum.js.map
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getPaginationParams = getPaginationParams;
exports.buildPaginationMeta = buildPaginationMeta;
function getPaginationParams(query) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;
    return { page, limit, skip, take: limit };
}
function buildPaginationMeta(total, page, limit) {
    return {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit) || 0,
    };
}
//# sourceMappingURL=pagination.util.js.map
import { PaginationQueryDto } from '../dto/pagination.dto';
export declare function getPaginationParams(query: PaginationQueryDto): {
    page: number;
    limit: number;
    skip: number;
    take: number;
};
export declare function buildPaginationMeta(total: number, page: number, limit: number): {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
};

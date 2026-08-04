export declare class PaginationQueryDto {
    page?: number;
    limit?: number;
    sortBy?: string;
    sortOrder?: 'asc' | 'desc';
}
export declare class PaginationMetaDto {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
}
export declare class PaginatedResultDto<T> {
    items: T[];
    meta: PaginationMetaDto;
}

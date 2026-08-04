import { Prisma, User } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
export declare class UsersRepository {
    private readonly prisma;
    constructor(prisma: PrismaService);
    create(data: Prisma.UserCreateInput): Prisma.Prisma__UserClient<{
        id: string;
        email: string | null;
        passwordHash: string | null;
        name: string;
        lastLoginAt: Date | null;
        createdAt: Date;
        updatedAt: Date;
        phone: string;
        role: import("@prisma/client").$Enums.UserRole;
        status: import("@prisma/client").$Enums.UserStatus;
        phoneVerified: boolean;
        phoneVerifiedAt: Date | null;
        deletedAt: Date | null;
    }, never, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
    findByEmail(email: string): Prisma.Prisma__UserClient<{
        id: string;
        email: string | null;
        passwordHash: string | null;
        name: string;
        lastLoginAt: Date | null;
        createdAt: Date;
        updatedAt: Date;
        phone: string;
        role: import("@prisma/client").$Enums.UserRole;
        status: import("@prisma/client").$Enums.UserStatus;
        phoneVerified: boolean;
        phoneVerifiedAt: Date | null;
        deletedAt: Date | null;
    } | null, null, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
    findByPhone(phone: string): Prisma.Prisma__UserClient<{
        id: string;
        email: string | null;
        passwordHash: string | null;
        name: string;
        lastLoginAt: Date | null;
        createdAt: Date;
        updatedAt: Date;
        phone: string;
        role: import("@prisma/client").$Enums.UserRole;
        status: import("@prisma/client").$Enums.UserStatus;
        phoneVerified: boolean;
        phoneVerifiedAt: Date | null;
        deletedAt: Date | null;
    } | null, null, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
    findById(id: string): Prisma.Prisma__UserClient<({
        employeeProfile: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            userId: string;
            summary: string | null;
            headline: string | null;
            location: string | null;
        } | null;
        employerProfile: ({
            company: {
                id: string;
                name: string;
                createdAt: Date;
                updatedAt: Date;
                description: string | null;
                deletedAt: Date | null;
                location: string | null;
                size: string | null;
                employerId: string;
                slug: string;
                website: string | null;
                industry: string | null;
                logoUrl: string | null;
            } | null;
        } & {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            userId: string;
            designation: string | null;
        }) | null;
    } & {
        id: string;
        email: string | null;
        passwordHash: string | null;
        name: string;
        lastLoginAt: Date | null;
        createdAt: Date;
        updatedAt: Date;
        phone: string;
        role: import("@prisma/client").$Enums.UserRole;
        status: import("@prisma/client").$Enums.UserStatus;
        phoneVerified: boolean;
        phoneVerifiedAt: Date | null;
        deletedAt: Date | null;
    }) | null, null, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
    update(id: string, data: Prisma.UserUpdateInput): Prisma.Prisma__UserClient<{
        id: string;
        email: string | null;
        passwordHash: string | null;
        name: string;
        lastLoginAt: Date | null;
        createdAt: Date;
        updatedAt: Date;
        phone: string;
        role: import("@prisma/client").$Enums.UserRole;
        status: import("@prisma/client").$Enums.UserStatus;
        phoneVerified: boolean;
        phoneVerifiedAt: Date | null;
        deletedAt: Date | null;
    }, never, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
    createProfileForRole(user: User): Prisma.Prisma__EmployeeProfileClient<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        summary: string | null;
        headline: string | null;
        location: string | null;
    }, never, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions> | Prisma.Prisma__EmployerProfileClient<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        designation: string | null;
    }, never, import("@prisma/client/runtime/library").DefaultArgs, Prisma.PrismaClientOptions>;
}

import { AdminPermission } from '../src/common/constants/roles.enum';
import { PrismaClient } from '@prisma/client';
import * as argon2 from 'argon2';

const prisma = new PrismaClient();

async function main() {
  const email = process.env.ADMIN_SEED_EMAIL ?? 'admin@jobportal.com';
  const password = process.env.ADMIN_SEED_PASSWORD ?? 'Admin@123456';
  const name = process.env.ADMIN_SEED_NAME ?? 'Super Admin';

  const passwordHash = await argon2.hash(password);

  await prisma.admin.upsert({
    where: { email },
    update: {
      passwordHash,
      name,
      isActive: true,
      permissions: Object.values(AdminPermission),
    },
    create: {
      email,
      passwordHash,
      name,
      isActive: true,
      permissions: Object.values(AdminPermission),
    },
  });

  console.log(`Seeded admin: ${email}`);
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

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

  // Seed sample Employer & Company
  const employerUser = await prisma.user.upsert({
    where: { phone: '+14155552671' },
    update: {},
    create: {
      phone: '+14155552671',
      email: 'employer@techcorp.com',
      name: 'TechCorp Hiring',
      role: 'EMPLOYER',
      status: 'ACTIVE',
      phoneVerified: true,
      employerProfile: {
        create: {
          designation: 'Hiring Manager',
          company: {
            create: {
              name: 'TechCorp Solutions',
              slug: 'techcorp-solutions',
              description: 'Leading global cloud & mobile software firm',
              industry: 'Software',
              location: 'San Francisco, CA / Remote',
            },
          },
        },
      },
    },
    include: { employerProfile: { include: { company: true } } },
  });

  const company = employerUser.employerProfile?.company;
  if (company) {
    const jobsData = [
      {
        title: 'Senior Flutter Mobile Engineer',
        slug: 'senior-flutter-mobile-engineer',
        description: 'Build production Flutter applications with clean architecture and Riverpod/Provider.',
        jobType: 'FULL_TIME' as const,
        location: 'Remote',
        salaryMin: 120000,
        salaryMax: 160000,
        status: 'PUBLISHED' as const,
      },
      {
        title: 'Full-Stack NestJS & React Architect',
        slug: 'full-stack-nestjs-react-architect',
        description: 'Architect scalable NestJS microservices and TypeScript frontend applications.',
        jobType: 'FULL_TIME' as const,
        location: 'Hybrid / New York',
        salaryMin: 130000,
        salaryMax: 170000,
        status: 'PUBLISHED' as const,
      },
      {
        title: 'Lead UI/UX Mobile Product Designer',
        slug: 'lead-ui-ux-mobile-product-designer',
        description: 'Design intuitive design systems and modern user experiences for iOS & Android.',
        jobType: 'CONTRACT' as const,
        location: 'San Francisco, CA',
        salaryMin: 95000,
        salaryMax: 125000,
        status: 'PUBLISHED' as const,
      },
    ];

    for (const job of jobsData) {
      await prisma.job.upsert({
        where: { companyId_slug: { companyId: company.id, slug: job.slug } },
        update: job,
        create: {
          ...job,
          companyId: company.id,
        },
      });
    }
    console.log('Seeded sample jobs into Supabase database!');
  }
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

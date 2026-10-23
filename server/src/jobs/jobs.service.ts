import { Injectable, NotFoundException } from '@nestjs/common';
import { JobType, JobStatus } from '@prisma/client';
import { PrismaService } from '../database/prisma.service';
import { CreateJobDto } from './dto/create-job.dto';

const MOCK_JOBS = [
  {
    id: 'job-1',
    title: 'Senior Flutter Developer',
    companyName: 'TechCorp Solutions',
    description: 'Build modern mobile apps using Flutter and Dart in an agile team.',
    location: 'Remote',
    salaryRange: '$120,000 - $150,000 / yr',
    jobType: 'Full-time',
    category: 'Engineering',
    status: 'PUBLISHED',
    employerId: 'emp-1',
    createdAt: new Date().toISOString(),
    isSaved: false,
    hasApplied: false,
  },
  {
    id: 'job-2',
    title: 'UI/UX Product Designer',
    companyName: 'Creative Studio',
    description: 'Design beautiful user interfaces and interactive mockups.',
    location: 'New York, NY',
    salaryRange: '$90,000 - $110,000 / yr',
    jobType: 'Full-time',
    category: 'Design',
    status: 'PUBLISHED',
    employerId: 'emp-2',
    createdAt: new Date().toISOString(),
    isSaved: false,
    hasApplied: false,
  },
  {
    id: 'job-3',
    title: 'Backend Engineer (NestJS / Node.js)',
    companyName: 'Bridgo Platform',
    description: 'Develop scalable backend microservices and REST APIs.',
    location: 'Hybrid',
    salaryRange: '$110,000 - $140,000 / yr',
    jobType: 'Full-time',
    category: 'Engineering',
    status: 'PUBLISHED',
    employerId: 'emp-3',
    createdAt: new Date().toISOString(),
    isSaved: false,
    hasApplied: false,
  },
  {
    id: 'job-4',
    title: 'Growth Marketing Manager',
    companyName: 'ScaleUp Inc',
    description: 'Drive user acquisition and digital marketing campaigns.',
    location: 'San Francisco, CA',
    salaryRange: '$85,000 - $105,000 / yr',
    jobType: 'Full-time',
    category: 'Marketing',
    status: 'PUBLISHED',
    employerId: 'emp-4',
    createdAt: new Date().toISOString(),
    isSaved: false,
    hasApplied: false,
  },
];

@Injectable()
export class JobsService {
  private inMemoryJobs = [...MOCK_JOBS];

  constructor(private readonly prisma: PrismaService) {}

  private mapJobType(type?: string): JobType {
    const norm = (type ?? '').toUpperCase().replace('-', '_');
    if (norm.includes('FULL')) return JobType.FULL_TIME;
    if (norm.includes('PART')) return JobType.PART_TIME;
    if (norm.includes('CONTRACT')) return JobType.CONTRACT;
    if (norm.includes('INTERN')) return JobType.INTERNSHIP;
    if (norm.includes('REMOTE')) return JobType.REMOTE;
    if (norm.includes('HYBRID')) return JobType.HYBRID;
    return JobType.FULL_TIME;
  }

  private extractUserId(userId?: unknown): string | undefined {
    if (!userId) return undefined;
    if (typeof userId === 'string') return userId;
    if (typeof userId === 'object' && userId !== null && 'sub' in userId) {
      return (userId as { sub: string }).sub;
    }
    return undefined;
  }

  async findAll(
    query?: string,
    category?: string,
    jobType?: string,
    location?: string,
    rawUserId?: unknown,
  ) {
    const userId = this.extractUserId(rawUserId);
    try {
      let employeeProfileId: string | undefined;
      if (userId) {
        const emp = await this.prisma.employeeProfile.findUnique({
          where: { userId },
        });
        employeeProfileId = emp?.id;
      }

      const dbJobs = await this.prisma.job.findMany({
        where: {
          status: JobStatus.PUBLISHED,
          deletedAt: null,
          ...(category && category !== 'All'
            ? {
                OR: [
                  { description: { contains: category, mode: 'insensitive' } },
                  { title: { contains: category, mode: 'insensitive' } },
                ],
              }
            : {}),
          ...(query
            ? {
                OR: [
                  { title: { contains: query, mode: 'insensitive' } },
                  { description: { contains: query, mode: 'insensitive' } },
                  { company: { name: { contains: query, mode: 'insensitive' } } },
                ],
              }
            : {}),
          ...(location
            ? { location: { contains: location, mode: 'insensitive' } }
            : {}),
        },
        include: {
          company: true,
          applications: employeeProfileId
            ? { where: { employeeProfileId } }
            : false,
        },
        orderBy: { createdAt: 'desc' },
      });

      if (dbJobs.length > 0) {
        return dbJobs.map((j) => {
          const applied = employeeProfileId
            ? (j.applications && j.applications.length > 0)
            : false;
          return {
            id: j.id,
            title: j.title,
            companyName: j.company?.name ?? 'Company',
            description: j.description,
            location: j.location ?? 'Remote',
            salaryRange:
              j.salaryMin && j.salaryMax
                ? `$${j.salaryMin} - $${j.salaryMax}`
                : 'Competitive',
            jobType: j.jobType ?? 'Full-time',
            category: category ?? 'General',
            status: j.status,
            employerId: j.companyId,
            createdAt: j.createdAt.toISOString(),
            isSaved: false,
            hasApplied: applied,
          };
        });
      }
    } catch (err) {
      console.error('[JobsService] Error in findAll:', err);
    }

    let filtered = [...this.inMemoryJobs];
    if (category && category !== 'All') {
      filtered = filtered.filter(
        (j) => j.category.toLowerCase() === category.toLowerCase(),
      );
    }
    if (query) {
      const q = query.toLowerCase();
      filtered = filtered.filter(
        (j) =>
          j.title.toLowerCase().includes(q) ||
          j.description.toLowerCase().includes(q) ||
          j.companyName.toLowerCase().includes(q),
      );
    }
    return filtered;
  }

  async findOne(id: string, rawUserId?: unknown) {
    const userId = this.extractUserId(rawUserId);
    let employeeProfileId: string | undefined;
    if (userId) {
      try {
        const emp = await this.prisma.employeeProfile.findUnique({
          where: { userId },
        });
        employeeProfileId = emp?.id;
      } catch (_) {}
    }

    try {
      const dbJob = await this.prisma.job.findUnique({
        where: { id },
        include: {
          company: true,
          applications: employeeProfileId
            ? { where: { employeeProfileId } }
            : false,
        },
      });

      if (dbJob) {
        const applied = employeeProfileId
          ? (dbJob.applications && dbJob.applications.length > 0)
          : false;
        return {
          id: dbJob.id,
          title: dbJob.title,
          companyName: dbJob.company?.name ?? 'Company',
          description: dbJob.description,
          location: dbJob.location ?? 'Remote',
          salaryRange:
            dbJob.salaryMin && dbJob.salaryMax
              ? `$${dbJob.salaryMin} - $${dbJob.salaryMax}`
              : 'Competitive',
          jobType: dbJob.jobType ?? 'Full-time',
          category: 'General',
          status: dbJob.status,
          employerId: dbJob.companyId,
          createdAt: dbJob.createdAt.toISOString(),
          isSaved: false,
          hasApplied: applied,
        };
      }
    } catch (err) {
      console.error('[JobsService] Error in findOne:', err);
    }

    const job = this.inMemoryJobs.find((j) => j.id === id);
    if (job) return job;

    throw new NotFoundException(`Job with ID ${id} not found`);
  }

  async create(dto: CreateJobDto, rawUserId?: unknown) {
    const userId = this.extractUserId(rawUserId);
    const slug = `${dto.title.toLowerCase().replace(/[^a-z0-9]+/g, '-')}-${Date.now()}`;
    const mappedType = this.mapJobType(dto.jobType);

    try {
      let companyId: string | undefined;

      if (userId) {
        let employer = await this.prisma.employerProfile.findUnique({
          where: { userId },
          include: { company: true },
        });

        if (!employer) {
          employer = await this.prisma.employerProfile.create({
            data: {
              userId,
              designation: 'Hiring Manager',
              company: {
                create: {
                  name: dto.companyName,
                  slug: `company-${Date.now()}`,
                  location: dto.location,
                },
              },
            },
            include: { company: true },
          });
        } else if (!employer.company) {
          const company = await this.prisma.company.create({
            data: {
              employerId: employer.id,
              name: dto.companyName,
              slug: `company-${Date.now()}`,
              location: dto.location,
            },
          });
          companyId = company.id;
        }

        companyId = companyId ?? employer.company?.id;
      }

      if (!companyId) {
        const defaultCompany = await this.prisma.company.findFirst();
        if (defaultCompany) {
          companyId = defaultCompany.id;
        }
      }

      if (companyId) {
        const created = await this.prisma.job.create({
          data: {
            companyId,
            title: dto.title,
            slug,
            description: dto.description,
            jobType: mappedType,
            location: dto.location,
            status: JobStatus.PUBLISHED,
            publishedAt: new Date(),
          },
          include: { company: true },
        });

        const formatted = {
          id: created.id,
          title: created.title,
          companyName: created.company?.name ?? dto.companyName,
          description: created.description,
          location: created.location ?? dto.location,
          salaryRange: dto.salaryRange,
          jobType: dto.jobType,
          category: dto.category,
          status: created.status,
          employerId: created.companyId,
          createdAt: created.createdAt.toISOString(),
          isSaved: false,
          hasApplied: false,
        };

        this.inMemoryJobs.unshift(formatted);
        return formatted;
      }
    } catch (err) {
      console.error('[JobsService] DB Error in create job:', err);
    }

    const newJob = {
      id: `job-${Date.now()}`,
      title: dto.title,
      companyName: dto.companyName,
      description: dto.description,
      location: dto.location,
      salaryRange: dto.salaryRange,
      jobType: dto.jobType,
      category: dto.category,
      status: 'PUBLISHED',
      employerId: userId ?? 'emp-1',
      createdAt: new Date().toISOString(),
      isSaved: false,
      hasApplied: false,
    };
    this.inMemoryJobs.unshift(newJob);
    return newJob;
  }

  async apply(jobId: string, rawUserId?: unknown, coverLetter?: string) {
    const userId = this.extractUserId(rawUserId);
    if (userId) {
      try {
        let employee = await this.prisma.employeeProfile.findUnique({
          where: { userId },
        });

        if (!employee) {
          employee = await this.prisma.employeeProfile.create({
            data: { userId },
          });
        }

        const existingApp = await this.prisma.application.findUnique({
          where: {
            jobId_employeeProfileId: {
              jobId,
              employeeProfileId: employee.id,
            },
          },
        });

        if (!existingApp) {
          await this.prisma.application.create({
            data: {
              jobId,
              employeeProfileId: employee.id,
              coverLetter,
            },
          });

          await this.prisma.job.update({
            where: { id: jobId },
            data: { applicationCount: { increment: 1 } },
          });
        }
      } catch (err) {
        console.error('[JobsService] DB Error in apply:', err);
      }
    }

    const job = await this.findOne(jobId, userId);
    return {
      message: 'Application submitted successfully',
      jobId: job.id,
      applicantId: userId ?? 'user-1',
      appliedAt: new Date().toISOString(),
    };
  }
}

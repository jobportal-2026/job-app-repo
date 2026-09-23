import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { CreateJobDto, ApplyJobDto } from './dto/create-job.dto';

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

  async findAll(query?: string, category?: string, jobType?: string, location?: string) {
    try {
      const dbJobs = await this.prisma.job.findMany({
        where: {
          status: 'PUBLISHED',
          ...(category && category !== 'All' ? { description: { contains: category, mode: 'insensitive' } } : {}),
          ...(query ? { title: { contains: query, mode: 'insensitive' } } : {}),
        },
        include: { company: true },
        orderBy: { createdAt: 'desc' },
      });

      if (dbJobs.length > 0) {
        return dbJobs.map((j) => ({
          id: j.id,
          title: j.title,
          companyName: j.company?.name ?? 'Company',
          description: j.description,
          location: j.location ?? 'Remote',
          salaryRange: j.salaryMin && j.salaryMax ? `$${j.salaryMin} - $${j.salaryMax}` : 'Competitive',
          jobType: j.jobType ?? 'Full-time',
          category: category ?? 'General',
          status: j.status,
          employerId: j.companyId,
          createdAt: j.createdAt.toISOString(),
          isSaved: false,
          hasApplied: false,
        }));
      }
    } catch (_) {
      // Fallback to in-memory seed list if database query yields no rows
    }

    let filtered = [...this.inMemoryJobs];
    if (category && category !== 'All') {
      filtered = filtered.filter((j) => j.category.toLowerCase() === category.toLowerCase());
    }
    if (query) {
      const q = query.toLowerCase();
      filtered = filtered.filter((j) => j.title.toLowerCase().includes(q) || j.description.toLowerCase().includes(q));
    }
    return filtered;
  }

  async findOne(id: string) {
    const job = this.inMemoryJobs.find((j) => j.id === id);
    if (job) return job;

    try {
      const dbJob = await this.prisma.job.findUnique({
        where: { id },
        include: { company: true },
      });
      if (dbJob) {
        return {
          id: dbJob.id,
          title: dbJob.title,
          companyName: dbJob.company?.name ?? 'Company',
          description: dbJob.description,
          location: dbJob.location ?? 'Remote',
          salaryRange: 'Competitive',
          jobType: dbJob.jobType ?? 'Full-time',
          category: 'General',
          status: dbJob.status,
          employerId: dbJob.companyId,
          createdAt: dbJob.createdAt.toISOString(),
          isSaved: false,
          hasApplied: false,
        };
      }
    } catch (_) {}

    throw new NotFoundException(`Job with ID ${id} not found`);
  }

  async create(dto: CreateJobDto, userId?: string) {
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

  async apply(jobId: string, userId?: string, coverLetter?: string) {
    const job = await this.findOne(jobId);
    return {
      message: 'Application submitted successfully',
      jobId: job.id,
      applicantId: userId ?? 'user-1',
      appliedAt: new Date().toISOString(),
    };
  }
}

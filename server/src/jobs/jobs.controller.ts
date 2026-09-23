import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
} from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Public } from '../common/decorators/public.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateJobDto, ApplyJobDto } from './dto/create-job.dto';
import { JobsService } from './jobs.service';

@ApiTags('Jobs')
@Controller('jobs')
export class JobsController {
  constructor(private readonly jobsService: JobsService) {}

  @Public()
  @Get()
  @ApiOperation({ summary: 'Get list of jobs' })
  async getJobs(
    @Query('q') query?: string,
    @Query('category') category?: string,
    @Query('jobType') jobType?: string,
    @Query('location') location?: string,
  ) {
    return this.jobsService.findAll(query, category, jobType, location);
  }

  @Public()
  @Get(':id')
  @ApiOperation({ summary: 'Get single job details' })
  async getJobById(@Param('id') id: string) {
    return this.jobsService.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create new job posting' })
  async createJob(
    @Body() dto: CreateJobDto,
    @CurrentUser('id') userId?: string,
  ) {
    return this.jobsService.create(dto, userId);
  }

  @Post(':id/apply')
  @ApiOperation({ summary: 'Apply for a job' })
  async applyJob(
    @Param('id') id: string,
    @Body() dto: ApplyJobDto,
    @CurrentUser('id') userId?: string,
  ) {
    return this.jobsService.apply(id, userId, dto.coverLetter);
  }
}

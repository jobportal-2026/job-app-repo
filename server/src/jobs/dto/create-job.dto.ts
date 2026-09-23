import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateJobDto {
  @ApiProperty({ example: 'Senior Flutter Developer' })
  @IsString()
  @IsNotEmpty()
  title!: string;

  @ApiProperty({ example: 'TechCorp' })
  @IsString()
  @IsNotEmpty()
  companyName!: string;

  @ApiProperty({ example: 'We are looking for a Flutter expert...' })
  @IsString()
  @IsNotEmpty()
  description!: string;

  @ApiProperty({ example: 'Remote / New York, NY' })
  @IsString()
  @IsNotEmpty()
  location!: string;

  @ApiProperty({ example: '$120,000 - $150,000' })
  @IsString()
  @IsNotEmpty()
  salaryRange!: string;

  @ApiProperty({ example: 'Full-time' })
  @IsString()
  @IsNotEmpty()
  jobType!: string;

  @ApiProperty({ example: 'Engineering' })
  @IsString()
  @IsNotEmpty()
  category!: string;
}

export class ApplyJobDto {
  @ApiProperty({ example: 'I am excited to apply for this role...' })
  @IsString()
  @IsOptional()
  coverLetter?: string;
}

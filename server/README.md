# Job Portal Backend

NestJS backend API for the Job Portal platform. It supports employee/employer authentication, phone OTP verification, Google OAuth, isolated admin authentication, Prisma/PostgreSQL persistence, Swagger docs, and Postman test collections.

## Stack

- Node.js 22+
- NestJS 11 + TypeScript
- PostgreSQL + Prisma ORM
- JWT access/refresh tokens
- Argon2 password hashing
- Twilio SMS OTP support, with terminal OTP logs in development
- Google OAuth support
- Swagger at `/api/docs`
- Docker Compose for API + PostgreSQL + Redis

## Project Structure

```text
server/
  src/
    auth/          # Employee/employer auth, OTP, Google OAuth
    admin/         # Isolated admin auth
    common/        # Guards, decorators, filters, utils, constants
    config/        # Environment validation/config module
    database/      # Prisma service/module
    shared/        # SMS, mail, audit, health modules
  prisma/
    schema.prisma  # Database schema
    seed.ts        # Admin seed script
    migrations/    # Prisma migrations
  docker/          # Dockerfile and docker-compose.yml
  docs/            # Setup, API, Postman, architecture docs
  postman/         # Importable Postman collection/environment
```

## Prerequisites

Install these before running the server:

- Node.js `22+`
- pnpm `10+`
- PostgreSQL `16+` for local development, or Docker Desktop if you want Docker to run PostgreSQL
- Postman optional, for API testing

Enable pnpm through Corepack if it is not already enabled:

```bash
corepack enable
```

Check versions:

```bash
node -v
pnpm -v
```

## Environment Setup

From the repository root:

```bash
cd server
```

Create your local environment file:

```bash
cp .env.example .env
```

On Windows PowerShell, if `cp` is not available:

```powershell
Copy-Item .env.example .env
```

Minimum required environment values:

```env
NODE_ENV=development
PORT=5000
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/job_portal?schema=public

JWT_SECRET=change-me-user-access-secret
JWT_REFRESH_SECRET=change-me-user-refresh-secret
ADMIN_JWT_SECRET=change-me-admin-access-secret
ADMIN_JWT_REFRESH_SECRET=change-me-admin-refresh-secret
```

For real deployments, replace every JWT secret with a long random value. You can generate one in PowerShell:

```powershell
[Convert]::ToBase64String((1..48 | ForEach-Object { Get-Random -Maximum 256 }) -as [byte[]])
```

Run that command four times and use a different value for each JWT secret.

## Install Dependencies

```bash
pnpm install
```

This project uses `pnpm@10.12.1` as declared in `package.json`.

## Run Locally With PostgreSQL Installed

Use this path when PostgreSQL is already installed on your machine.

1. Create the database:

```sql
CREATE DATABASE job_portal;
```

2. Make sure `.env` points to that database:

```env
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/job_portal?schema=public
```

3. Generate Prisma Client:

```bash
pnpm run db:generate
```

4. Apply migrations:

```bash
pnpm exec prisma migrate deploy
```

For active schema development, you can use the project script instead:

```bash
pnpm run db:migrate
```

5. Seed the first admin account:

```bash
pnpm run db:seed
```

Default seeded admin credentials come from `.env.example`:

```text
Email: admin@jobportal.com
Password: Admin@123456
```

You can change them before seeding:

```env
ADMIN_SEED_EMAIL=admin@jobportal.com
ADMIN_SEED_PASSWORD=Admin@123456
ADMIN_SEED_NAME=Super Admin
```

6. Start the development server:

```bash
pnpm run start:dev
```

## Run Locally With Docker PostgreSQL

Use this path if you want Docker to run the database services but still run NestJS on your machine.

```bash
cd server
docker compose --project-directory . -f docker/docker-compose.yml up -d postgres redis
pnpm install
pnpm run db:generate
pnpm exec prisma migrate deploy
pnpm run db:seed
pnpm run start:dev
```

The compose file creates PostgreSQL with:

```text
Host: localhost
Port: 5432
Database: job_portal
User: postgres
Password: postgres
```

So the default `.env.example` `DATABASE_URL` works with this setup.

## Run Everything With Docker Compose

Use this path to run the API, PostgreSQL, and Redis together in containers.

Before starting the full Docker stack, set the database host in `.env` to the Compose service name:

```env
DATABASE_URL=postgresql://postgres:postgres@postgres:5432/job_portal?schema=public
```

Use `localhost` only when the NestJS server runs on your machine. Use `postgres` when the NestJS server runs inside Docker Compose.

```bash
cd server
cp .env.example .env
docker compose --project-directory . -f docker/docker-compose.yml up --build
```

PowerShell alternative:

```powershell
Copy-Item .env.example .env
docker compose --project-directory . -f docker/docker-compose.yml up --build
```

The API container runs migrations on startup:

```bash
pnpm exec prisma migrate deploy && node dist/main.js
```

If you need the admin seed in Docker, run:

```bash
docker compose --project-directory . -f docker/docker-compose.yml exec api pnpm run db:seed
```

Stop containers:

```bash
docker compose --project-directory . -f docker/docker-compose.yml down
```

Stop containers and remove the PostgreSQL volume:

```bash
docker compose --project-directory . -f docker/docker-compose.yml down -v
```

## Server URLs

When `PORT=5000`:

| URL | Purpose |
|-----|---------|
| `http://localhost:5000/api/v1` | API base URL |
| `http://localhost:5000/api/v1/health` | Health check |
| `http://localhost:5000/api/docs` | Swagger UI |

Health check:

```bash
curl http://localhost:5000/api/v1/health
```

## Useful Scripts

| Command | Purpose |
|---------|---------|
| `pnpm run start` | Start NestJS once |
| `pnpm run start:dev` | Start with watch mode for development |
| `pnpm run start:debug` | Start with debugger and watch mode |
| `pnpm run build` | Compile TypeScript to `dist/` |
| `pnpm run start:prod` | Run compiled production build from `dist/main` |
| `pnpm run lint` | Run ESLint with auto-fix |
| `pnpm run format` | Format TypeScript files with Prettier |
| `pnpm run db:generate` | Generate Prisma Client |
| `pnpm run db:migrate` | Run `prisma migrate dev` |
| `pnpm run db:seed` | Seed/update the first admin user |
| `pnpm exec prisma studio` | Open Prisma Studio database UI |

Production-style local run:

```bash
pnpm run build
pnpm run start:prod
```

## OTP Behavior

Registration, resend OTP, phone binding, and password reset use phone OTP.

If Twilio variables are empty and `NODE_ENV=development`, SMS sending is skipped and the OTP is printed in the server terminal:

```text
[SmsService] [DEV ONLY] OTP for +15551234567: 482913
```

Use that code in:

- `POST /auth/verify-phone`
- `POST /auth/bind-phone`
- `POST /auth/reset-password`

Defaults:

```env
OTP_TTL_SECONDS=300
OTP_MAX_ATTEMPTS=5
```

OTP resend is limited to 3 requests per phone per hour.

## Optional Twilio Setup

Set these only when you want real SMS delivery:

```env
TWILIO_ACCOUNT_SID=ACxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxx
TWILIO_PHONE_NUMBER=+1xxxxxxxxxx
```

In development, leaving them blank is fine.

## Optional Google OAuth Setup

Create a Google OAuth 2.0 Client ID for a web application and add this authorized redirect URI:

```text
http://localhost:5000/api/v1/auth/google/callback
```

Then set:

```env
GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=xxx
GOOGLE_CALLBACK_URL=http://localhost:5000/api/v1/auth/google/callback
```

Start OAuth in a browser:

```text
http://localhost:5000/api/v1/auth/google?role=employee
http://localhost:5000/api/v1/auth/google?role=employer
```

## Main Endpoints

Base URL:

```text
http://localhost:5000/api/v1
```

User auth:

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/auth/register` | Register employee/employer |
| `POST` | `/auth/verify-phone` | Verify phone OTP |
| `POST` | `/auth/resend-otp` | Resend OTP |
| `POST` | `/auth/login` | Login |
| `POST` | `/auth/refresh` | Refresh tokens |
| `POST` | `/auth/logout` | Logout |
| `GET` | `/auth/me` | Current user |
| `POST` | `/auth/change-password` | Change password |
| `POST` | `/auth/forgot-password` | Request password reset OTP |
| `POST` | `/auth/reset-password` | Reset password |
| `GET` | `/auth/google` | Start Google OAuth |
| `GET` | `/auth/google/callback` | Google OAuth callback |
| `POST` | `/auth/bind-phone` | Bind phone after Google signup |

Admin auth:

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/admin/auth/login` | Admin login |
| `POST` | `/admin/auth/refresh` | Admin token refresh |
| `POST` | `/admin/auth/logout` | Admin logout |
| `GET` | `/admin/auth/me` | Current admin |

## Testing With Postman

Import both files:

- `postman/Job-Portal-Backend.postman_collection.json`
- `postman/Job-Portal-Local.postman_environment.json`

Select the `Job Portal Local` environment and run:

```text
Health Check -> Register Employee -> read OTP from terminal -> Verify Phone -> Login Employee -> Get Current User
```

Admin flow:

```text
pnpm run db:seed -> Admin Login -> Admin Me -> Admin Refresh Token -> Admin Logout
```

More details are in [docs/POSTMAN.md](docs/POSTMAN.md).

## Documentation

| Doc | Description |
|-----|-------------|
| [docs/SETUP.md](docs/SETUP.md) | Setup, env, Docker, run, troubleshoot |
| [docs/LOCAL-DEV.md](docs/LOCAL-DEV.md) | Local setup without Docker |
| [docs/API.md](docs/API.md) | API endpoint reference |
| [docs/POSTMAN.md](docs/POSTMAN.md) | Postman import and test flows |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Backend architecture notes |
| [postman/](postman/) | Importable Postman files |

## Response Format

Successful responses are wrapped like this:

```json
{
  "success": true,
  "message": "",
  "data": {}
}
```

Error responses use the same wrapper with `success: false` and validation/business error details.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Can't reach database server` or Prisma `P1001` | Start PostgreSQL and verify `DATABASE_URL` |
| Environment validation error on boot | Copy `.env.example` to `.env` and fill all required values |
| Port already in use | Change `PORT` in `.env`, for example `PORT=5001` |
| `Phone verification required` on login | Complete `POST /auth/verify-phone` first |
| `Role mismatch` on login | Use the same role used during registration |
| `Phone already registered` | Use a different phone number or delete test data in Prisma Studio |
| Admin login fails | Run `pnpm run db:seed` and use `ADMIN_SEED_EMAIL` / `ADMIN_SEED_PASSWORD` |
| Google OAuth configuration error | Either fill `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` or leave Google OAuth unused |
| Docker cannot connect or pipe errors | Start Docker Desktop and rerun the compose command |

## Security Notes

- Change all JWT secrets before production.
- User and admin tokens use separate secrets and tables.
- Phone verification is required before user login.
- Refresh tokens are stored hashed and rotated.
- Passwords are hashed with Argon2.
- CORS origins are configured through `CORS_ORIGINS`.
- Do not commit real `.env` secrets.

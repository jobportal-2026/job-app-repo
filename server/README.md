# Job Portal Backend

NestJS backend for the Job Portal platform (Flutter mobile + Next.js admin).

## Documentation

| Doc | Description |
|-----|-------------|
| [docs/SETUP.md](docs/SETUP.md) | Install, env, Docker, run, troubleshoot |
| [docs/API.md](docs/API.md) | Full API reference (all endpoints) |
| [docs/POSTMAN.md](docs/POSTMAN.md) | Postman import + test flows |
| [docs/LOCAL-DEV.md](docs/LOCAL-DEV.md) | Local setup without Docker + NestJS guide |
| [postman/](postman/) | Importable Postman collection + environment |

## Stack

- NestJS 11, TypeScript
- PostgreSQL + Prisma ORM
- PostgreSQL + Prisma ORM (OTP + token blacklist in DB for local dev)
- Redis in production Docker only
- JWT auth (isolated admin realm)
- Twilio SMS OTP
- Swagger at `/api/docs`

## Quick Start

### 1. Prerequisites

- Node.js 22+
- pnpm 10+ (`corepack enable`)
- Docker optional — production only (`docker/`). Local dev needs PostgreSQL only.

### 2. Install

```bash
cd server
cp .env.example .env
pnpm install
```

### 3. Start infrastructure

```bash
docker compose -f docker/docker-compose.yml up -d postgres redis
```

### 4. Database

```bash
npx prisma migrate dev --name init
pnpm run db:seed
```

### 5. Run API

```bash
pnpm run start:dev
```

- API: `http://localhost:5000/api/v1`
- Swagger: `http://localhost:5000/api/docs`

## Auth Endpoints (v1)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/auth/register` | Register employee/employer |
| POST | `/auth/verify-phone` | Verify phone OTP |
| POST | `/auth/resend-otp` | Resend OTP |
| POST | `/auth/login` | Login |
| POST | `/auth/refresh` | Refresh tokens |
| POST | `/auth/logout` | Logout |
| GET | `/auth/me` | Current user |
| POST | `/auth/change-password` | Change password |
| POST | `/auth/forgot-password` | Password reset OTP |
| POST | `/auth/reset-password` | Reset password |
| GET | `/auth/google` | Google OAuth |
| POST | `/auth/bind-phone` | Bind phone after Google signup |

### Admin Auth (isolated)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/admin/auth/login` | Admin login |
| POST | `/admin/auth/refresh` | Admin refresh |
| POST | `/admin/auth/logout` | Admin logout |
| GET | `/admin/auth/me` | Current admin |

Default seeded admin: see `.env.example` (`ADMIN_SEED_EMAIL` / `ADMIN_SEED_PASSWORD`).

## Scripts

```bash
pnpm run start:dev    # Dev server
pnpm run build        # Production build
pnpm run db:seed      # Seed first admin
```

## Docker (full stack)

```bash
cp .env.example .env
docker compose -f docker/docker-compose.yml up --build
```

## Response Format

```json
{
  "success": true,
  "message": "",
  "data": {}
}
```

## Security Notes

- Change all JWT secrets in production
- Phone OTP required before login
- Admin auth uses separate JWT secrets and DB table
- One account = one role (employee OR employer)

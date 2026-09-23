# Local Dev Guide (No Docker)

Local machine only. Docker + Redis used in production (`docker/docker-compose.yml`).

---

## What you need locally

| Service | Required? | Notes |
|---------|-----------|-------|
| PostgreSQL | **Yes** | Install on Windows |
| Redis | **No** | Production only |
| Twilio | No | OTP prints in terminal |
| Google OAuth | No | Leave `GOOGLE_CLIENT_*` empty |

OTP + token blacklist → **PostgreSQL** (no Redis in dev).

---

## 1. Install PostgreSQL (Windows)

1. Download: https://www.postgresql.org/download/windows/
2. Install — remember `postgres` password
3. Create database:

```sql
CREATE DATABASE job_portal;
```

4. `.env`:

```env
PORT=5000
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/job_portal?schema=public
```

---

## 2. Migrate + seed + start

```bash
cd server
pnpm install
pnpm exec prisma migrate deploy
pnpm run db:seed
pnpm run start:dev
```

| URL | Purpose |
|-----|---------|
| http://localhost:5000/api/v1/health | Health |
| http://localhost:5000/api/docs | Swagger |

---

## 3. Postman test flow

Import `server/postman/*.json`

```
Register → OTP from terminal → Verify Phone → Login → Me
```

Terminal OTP:
```
[SmsService] [DEV ONLY] OTP for +15551234567: 482913
```

---

## NestJS for Node devs

| Express | NestJS |
|---------|--------|
| `router.post` | `@Post()` + `@Controller()` |
| `req.body` | `@Body() Dto` |
| `req.user` | `@CurrentUser()` |
| middleware | `Guard` / `Pipe` / `Interceptor` |

### Request flow

```
HTTP → Guard → ValidationPipe → Controller → Service → Repository → Prisma → JSON response
```

### Folders

```
src/auth/       # register, login, OTP
src/admin/      # admin auth
src/common/     # guards, filters, DTOs
src/database/   # Prisma
src/shared/     # sms, mail, audit
```

---

## Common errors

| Error | Fix |
|-------|-----|
| `Can't reach database server` | Start Postgres, fix `DATABASE_URL` |
| `Phone verification required` | Call `verify-phone` first |
| `OAuth2Strategy requires clientID` | Leave Google env empty |
| Port in use | `PORT=5001` in `.env` |

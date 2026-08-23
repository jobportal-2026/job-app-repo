# Setup Guide — Job Portal Backend

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | 22+ | Runtime |
| pnpm | 10+ | Package manager (via Corepack) |
| Docker Desktop | latest | Production only (`docker/`) |
| Postman | any | API testing (optional) |

Enable pnpm once:

```bash
corepack enable
```

---

## 1. Clone / open project

```bash
cd server
```

## 2. Environment

```bash
cp .env.example .env
```

Edit `.env` if needed. Minimum required for boot:

```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/job_portal?schema=public
JWT_SECRET=your-long-random-user-access-secret
JWT_REFRESH_SECRET=your-long-random-user-refresh-secret
ADMIN_JWT_SECRET=your-long-random-admin-access-secret
ADMIN_JWT_REFRESH_SECRET=your-long-random-admin-refresh-secret
```

Generate secrets (PowerShell):

```powershell
[Convert]::ToBase64String((1..48 | ForEach-Object { Get-Random -Maximum 256 }) -as [byte[]])
```

Run four times — one per JWT secret.

---

## 3. Start PostgreSQL locally

Install PostgreSQL for Windows. Create database `job_portal`. No Redis needed for local dev.

---

## 4. Database migrate + seed

```bash
pnpm install
npx prisma migrate deploy
pnpm run db:seed
```

Seed creates first admin:

| Field | Default |
|-------|---------|
| Email | `admin@jobportal.com` |
| Password | `Admin@123456` |

Override via `ADMIN_SEED_EMAIL`, `ADMIN_SEED_PASSWORD` in `.env`.

---

## 5. Run API

```bash
pnpm run start:dev
```

| URL | Purpose |
|-----|---------|
| http://localhost:5000/api/v1/health | Health check |
| http://localhost:5000/api/docs | Swagger UI |

---

## 6. Dev OTP (no Twilio)

If `TWILIO_*` vars empty, SMS skipped. In `NODE_ENV=development`, OTP prints in **server terminal**:

```
[SmsService] [DEV ONLY] OTP for +14155552671: 482913
```

Copy code → `POST /auth/verify-phone`. OTP TTL = 5 min (`OTP_TTL_SECONDS=300`).

---

## 7. Twilio (production-like SMS)

1. Create account at https://www.twilio.com
2. Get Account SID, Auth Token, phone number
3. Set in `.env`:

```env
TWILIO_ACCOUNT_SID=ACxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxx
TWILIO_PHONE_NUMBER=+1xxxxxxxxxx
```

---

## 8. Google OAuth (optional)

1. Google Cloud Console → APIs & Services → Credentials
2. OAuth 2.0 Client ID (Web)
3. Authorized redirect URI:

```
http://localhost:5000/api/v1/auth/google/callback
```

4. Set in `.env`:

```env
GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=xxx
GOOGLE_CALLBACK_URL=http://localhost:5000/api/v1/auth/google/callback
```

Test in browser (not Postman):

```
http://localhost:5000/api/v1/auth/google?role=employee
```

---

## 9. Docker full stack

```bash
docker compose -f docker/docker-compose.yml up --build
```

Runs API + Postgres + Redis. Ensure `.env` exists before build.

---

## 10. Useful commands

```bash
pnpm run start:dev      # Dev with hot reload
pnpm run build          # Compile
pnpm run start:prod     # Production
pnpm run db:seed        # Re-seed admin
pnpm exec prisma studio # DB GUI
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `P1001` DB connection | Start Postgres, check `DATABASE_URL` |
| Env validation error on boot | Copy `.env.example`, fill JWT secrets |
| `Phone already registered` | Use new phone or delete row in Prisma Studio |
| Login `Phone verification required` | Call `verify-phone` first |
| Login `Role mismatch` | `role` in body must match registration role |
| Docker pipe error | Start Docker Desktop |

# Architecture Overview — Module 1

What exists after Module 1 (Scaffold + Auth).

---

## Project structure

```
server/
├── docs/
│   ├── API.md              ← Full endpoint reference
│   ├── SETUP.md            ← Install + run + troubleshoot
│   ├── POSTMAN.md          ← Postman testing guide
│   └── ARCHITECTURE.md     ← This file
├── postman/
│   ├── Job-Portal-Backend.postman_collection.json
│   └── Job-Portal-Local.postman_environment.json
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts
├── docker/
├── src/
│   ├── main.ts
│   ├── config/
│   ├── database/
│   ├── common/
│   ├── shared/
│   ├── auth/
│   └── admin/
```

---

## Modules implemented

| Module | Status |
|--------|--------|
| `config` | ✅ Env validation |
| `database` | ✅ Prisma |
| `common` | ✅ Guards, filters, interceptors |
| `shared/sms` | ✅ Twilio + dev OTP log |
| `shared/mail` | ✅ Nodemailer |
| `shared/audit` | ✅ Audit logs |
| `shared/health` | ✅ Health endpoint |
| `auth` | ✅ User auth full |
| `admin/auth` | ✅ Isolated admin auth |

**Not yet:** profiles, companies, jobs, applications, notifications, admin CRUD.

---

## Auth isolation

```
POST /auth/*          → users + JWT_SECRET
POST /admin/auth/*    → admins + ADMIN_JWT_SECRET
```

No cross-realm tokens.

---

## Key decisions

| Topic | Choice |
|-------|--------|
| Verification | Phone OTP (not email gate) |
| Login | Email + password + role |
| Role | One per account |
| Tokens | 15m access / 7d refresh |
| Password | argon2id |

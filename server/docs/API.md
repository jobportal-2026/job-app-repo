# API Reference — Job Portal Backend v1

**Base URL:** `http://localhost:5000/api/v1`

**Swagger:** `http://localhost:5000/api/docs`

---

## Response format

### Success

```json
{
  "success": true,
  "message": "",
  "data": { }
}
```

### Error

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    { "field": "phone", "message": "phone must be valid E.164 format" }
  ]
}
```

---

## Authentication

### User auth (Employee / Employer)

| Header | Value |
|--------|-------|
| `Authorization` | `Bearer <accessToken>` |

Access token from `login` or `refresh`. Expires in **15 minutes**.

### Admin auth (isolated)

| Header | Value |
|--------|-------|
| `Authorization` | `Bearer <adminAccessToken>` |

From `POST /admin/auth/login`. **Different JWT secret** — user token never works on admin routes.

---

## Roles

| Value | Description |
|-------|-------------|
| `employee` | Job seeker (Flutter) |
| `employer` | Company / hiring (Flutter) |

One account = one role forever. Login `role` must match registered role.

---

## Health

### `GET /health`

No auth.

**Response `data`:**

```json
{
  "status": "ok",
  "timestamp": "2026-06-26T12:00:00.000Z"
}
```

---

## Auth — Employee / Employer

### `POST /auth/register`

Register new user. Sends phone OTP. Account stays `PENDING_PHONE_VERIFICATION` until verified.

**Auth:** None

**Body:**

```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "phone": "+14155552671",
  "password": "Password123",
  "role": "employee"
}
```

| Field | Required | Rules |
|-------|----------|-------|
| `name` | yes | string |
| `email` | no | valid email, unique if provided |
| `phone` | yes | E.164 e.g. `+14155552671`, unique |
| `password` | yes | min 8 chars |
| `role` | yes | `employee` or `employer` |

**Response `data`:**

```json
{
  "message": "Registration successful. Verify phone with OTP.",
  "userId": "uuid",
  "phone": "+14155552671"
}
```

**Errors:** `409` phone/email exists

---

### `POST /auth/verify-phone`

Verify registration OTP. Activates account.

**Auth:** None

**Body:**

```json
{
  "phone": "+14155552671",
  "code": "482913"
}
```

**Response `data`:**

```json
{
  "id": "uuid",
  "name": "Jane Doe",
  "email": "jane@example.com",
  "phone": "+14155552671",
  "role": "employee",
  "phoneVerified": true,
  "status": "ACTIVE"
}
```

---

### `POST /auth/resend-otp`

Resend registration OTP. Rate limit: **3 per hour** per phone.

**Auth:** None

**Body:**

```json
{
  "phone": "+14155552671"
}
```

---

### `POST /auth/login`

**Auth:** None

**Body:**

```json
{
  "email": "jane@example.com",
  "password": "Password123",
  "role": "employee"
}
```

| Field | Required | Notes |
|-------|----------|-------|
| `email` | yes | must exist on account |
| `password` | yes | |
| `role` | yes | must match stored role |

**Response `data`:**

```json
{
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "user": {
    "id": "uuid",
    "name": "Jane Doe",
    "email": "jane@example.com",
    "phone": "+14155552671",
    "role": "employee",
    "phoneVerified": true,
    "status": "ACTIVE"
  }
}
```

**Errors:**

| Status | Message |
|--------|---------|
| `401` | Invalid credentials |
| `403` | Phone verification required |
| `403` | Role mismatch |
| `403` | Account suspended |

---

### `POST /auth/refresh`

Rotate refresh token. Old refresh token revoked.

**Auth:** None

**Body:**

```json
{
  "refreshToken": "eyJ..."
}
```

**Response `data`:** Same shape as login (new token pair + user).

---

### `POST /auth/logout`

Revoke refresh token(s).

**Auth:** Bearer user access token

**Body (optional):**

```json
{
  "refreshToken": "eyJ..."
}
```

If `refreshToken` omitted → revokes all refresh tokens for user.

**Response `data`:**

```json
{
  "message": "Logged out successfully"
}
```

---

### `GET /auth/me`

Current authenticated user profile.

**Auth:** Bearer user access token

**Response `data`:** User object (same as login `user` field).

---

### `POST /auth/change-password`

**Auth:** Bearer user access token

**Body:**

```json
{
  "currentPassword": "Password123",
  "newPassword": "NewPassword456"
}
```

Revokes all refresh tokens after change.

---

### `POST /auth/forgot-password`

Send password reset OTP to phone. Always returns same message (no user enumeration).

**Auth:** None

**Body:**

```json
{
  "phone": "+14155552671"
}
```

**Response `data`:**

```json
{
  "message": "If the phone exists, an OTP has been sent"
}
```

---

### `POST /auth/reset-password`

**Auth:** None

**Body:**

```json
{
  "phone": "+14155552671",
  "code": "482913",
  "newPassword": "NewPassword456"
}
```

Revokes all refresh tokens.

---

### `GET /auth/google`

Start Google OAuth. **Browser only.**

```
GET /auth/google?role=employee
GET /auth/google?role=employer
```

Redirects to Google → callback.

---

### `GET /auth/google/callback`

Google redirect target. Returns JSON:

**New Google user (needs phone bind):**

```json
{
  "success": true,
  "message": "",
  "data": {
    "requiresPhoneBinding": true,
    "userId": "uuid",
    "message": "Google account linked. Bind and verify phone number."
  }
}
```

**Existing verified user:**

```json
{
  "success": true,
  "data": {
    "accessToken": "...",
    "refreshToken": "...",
    "user": { }
  }
}
```

---

### `POST /auth/bind-phone`

Bind + verify phone after Google signup.

**Auth:** None

**Step 1 — request OTP:**

```json
{
  "userId": "uuid-from-google-callback",
  "phone": "+14155552671"
}
```

**Step 2 — verify + get tokens:**

```json
{
  "userId": "uuid",
  "phone": "+14155552671",
  "code": "482913"
}
```

---

## Admin Auth (isolated)

### `POST /admin/auth/login`

**Auth:** None. Never accepts employee/employer credentials.

**Body:**

```json
{
  "email": "admin@jobportal.com",
  "password": "Admin@123456"
}
```

**Response `data`:**

```json
{
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "admin": {
    "id": "uuid",
    "email": "admin@jobportal.com",
    "name": "Super Admin",
    "permissions": [
      "users:read",
      "users:write",
      "jobs:moderate",
      "reports:manage",
      "analytics:read",
      "system:config"
    ]
  }
}
```

---

### `POST /admin/auth/refresh`

**Auth:** None

**Body:**

```json
{
  "refreshToken": "eyJ..."
}
```

---

### `POST /admin/auth/logout`

**Auth:** Bearer **admin** access token

**Body (optional):**

```json
{
  "refreshToken": "eyJ..."
}
```

---

### `GET /admin/auth/me`

**Auth:** Bearer **admin** access token

**Response `data`:**

```json
{
  "id": "uuid",
  "email": "admin@jobportal.com",
  "name": "Super Admin",
  "permissions": ["users:read", "..."]
}
```

---

## HTTP status codes

| Code | Meaning |
|------|---------|
| `200` | OK |
| `201` | Created |
| `400` | Validation / business error |
| `401` | Unauthorized |
| `403` | Forbidden (role, verification, suspended) |
| `404` | Not found |
| `409` | Conflict (duplicate phone/email) |
| `429` | Rate limit / OTP resend limit |

---

## Rate limiting

Global: **100 requests / minute / IP** (via `@nestjs/throttler`).

OTP resend: **3 / hour / phone**.

---

## Security notes

- Passwords hashed with **argon2id**
- Refresh tokens stored **hashed** in DB, rotated on refresh
- Admin + user use **separate** JWT secrets and DB tables
- Phone verification **required** before login
- Helmet + CORS + validation pipe enabled

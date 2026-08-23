# Postman Testing Guide

## Quick import

1. Open Postman
2. **Import** → select both files:
   - `postman/Job-Portal-Backend.postman_collection.json`
   - `postman/Job-Portal-Local.postman_environment.json`
3. Top-right dropdown → select **Job Portal Local**
4. Start server: `pnpm run start:dev`
5. Run **Health Check** first

---

## Environment variables (auto-set by collection)

| Variable | Set by | Used for |
|----------|--------|----------|
| `baseUrl` | manual | `http://localhost:5000/api/v1` |
| `accessToken` | Login script | User protected routes |
| `refreshToken` | Login script | Refresh / logout |
| `adminAccessToken` | Admin login script | Admin routes |
| `adminRefreshToken` | Admin login script | Admin refresh |
| `userId` | Register script | bind-phone |
| `phone` | manual | E.164 phone |
| `email` | manual | Login email |
| `password` | manual | Account password |
| `role` | manual | `employee` or `employer` |

---

## Recommended test order

### Employee flow

```
1. Health Check
2. Register Employee
3. (read OTP from server terminal — see SETUP.md)
4. Verify Phone
5. Login Employee          → saves accessToken + refreshToken
6. Get Current User (me)
7. Refresh Token
8. Change Password
9. Logout
```

### Employer flow

Same as employee. Change `role` to `employer` and use different `phone` / `email`.

### Admin flow

```
1. (run `pnpm run db:seed` first)
2. Admin Login             → saves adminAccessToken
3. Admin Me
4. Admin Refresh Token
5. Admin Logout
```

### Password reset flow

```
1. Register + Verify (or use existing user)
2. Forgot Password         → OTP in terminal
3. Reset Password
4. Login with new password
```

---

## Manual Postman setup (no import)

### Collection variables

Create collection → Variables:

| Key | Value |
|-----|-------|
| `baseUrl` | `http://localhost:5000/api/v1` |

### Auth header for protected routes

Tab **Authorization** → Type **Bearer Token** → Token: `{{accessToken}}`

For admin routes use `{{adminAccessToken}}`.

### Auto-save tokens (Login request Tests tab)

```javascript
const res = pm.response.json();
if (res.data?.accessToken) {
  pm.environment.set('accessToken', res.data.accessToken);
  pm.environment.set('refreshToken', res.data.refreshToken);
}
```

Admin login:

```javascript
const res = pm.response.json();
if (res.data?.accessToken) {
  pm.environment.set('adminAccessToken', res.data.accessToken);
  pm.environment.set('adminRefreshToken', res.data.refreshToken);
}
```

Register — save userId:

```javascript
const res = pm.response.json();
if (res.data?.userId) {
  pm.environment.set('userId', res.data.userId);
}
```

---

## Example requests

### Register

```
POST {{baseUrl}}/auth/register
Content-Type: application/json

{
  "name": "Test Employee",
  "email": "employee@test.com",
  "phone": "+15551234567",
  "password": "TestPass123",
  "role": "employee"
}
```

### Verify phone

```
POST {{baseUrl}}/auth/verify-phone
Content-Type: application/json

{
  "phone": "+15551234567",
  "code": "123456"
}
```

### Login

```
POST {{baseUrl}}/auth/login
Content-Type: application/json

{
  "email": "employee@test.com",
  "password": "TestPass123",
  "role": "employee"
}
```

### Me (protected)

```
GET {{baseUrl}}/auth/me
Authorization: Bearer {{accessToken}}
```

---

## Dev OTP — where to find code

Without Twilio, watch **API server terminal** after register / resend-otp / forgot-password:

```
[SmsService] [DEV ONLY] OTP for +15551234567: 482913
```

`NODE_ENV` must be `development` (default in `.env.example`).

---

## Common Postman errors

| Response | Cause | Fix |
|----------|-------|-----|
| `ECONNREFUSED` | Server down | `pnpm run start:dev` |
| `401 Unauthorized` on `/auth/me` | Token expired / missing | Re-login or refresh |
| `403 Role mismatch` | Wrong `role` in login | Match registration role |
| `403 Phone verification required` | Skipped verify-phone | Run verify first |
| `409 Phone already registered` | Duplicate phone | New phone or delete user in DB |
| `429 OTP resend limit` | Too many resends | Wait 1 hour or new phone |
| Admin `401` with user token | Wrong token type | Use `adminAccessToken` |

---

## Swagger alternative

Interactive docs: http://localhost:5000/api/docs

- Click **Authorize** → paste Bearer token
- Try endpoints in browser

Swagger better for quick single calls. Postman better for flows + env variables.

---

## cURL equivalents

**Health:**

```bash
curl http://localhost:5000/api/v1/health
```

**Register:**

```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Test\",\"email\":\"t@test.com\",\"phone\":\"+15551234567\",\"password\":\"TestPass123\",\"role\":\"employee\"}"
```

**Login:**

```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"t@test.com\",\"password\":\"TestPass123\",\"role\":\"employee\"}"
```

**Me:**

```bash
curl http://localhost:5000/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

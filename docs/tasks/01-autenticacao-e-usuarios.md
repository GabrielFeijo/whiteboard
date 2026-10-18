# Epic 1 — Authentication and Users

Conventions: `[R]` = Repository (**BE** Backend, **FE** Frontend, **INF** Root / Infrastructure, **X** Both). Estimate: **S** ≤ ½ day · **M** 1–2 days · **L** 3–5 days. Status: ⬜ Pending · ✅ Completed.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T1.1 | BE | Register/login with Argon2id password hashing, 15-minute access JWT | M | T0.5 | ✅ |
| T1.2 | BE | Opaque refresh token in HttpOnly cookie, atomic rotation and reuse detection | L | T1.1 | ✅ |
| T1.3 | BE | Progressive lockout + IP/email rate limiting via Redis | M | T1.1 | ✅ |
| T1.4 | BE | RBAC guards (`OWNER`/`EDITOR`/`VIEWER`) and decorators | M | T1.1 | ✅ |
| T1.5 | FE | Login/register UI, auth client, silent token refresh, in-memory access token | L | T1.2, T0.7 | ✅ |
| T1.6 | FE | Next.js protected routes middleware | S | T1.5 | ✅ |
| T1.7 | BE | `DELETE /me`: account deletion and `createdBy` data anonymization | M | T1.1 | ✅ |

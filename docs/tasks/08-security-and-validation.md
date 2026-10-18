# Epic 8 — Security and Validation (§14)

Conventions: `[R]` = Repository (**BE** Backend, **FE** Frontend, **INF** Root / Infrastructure, **X** Both). Estimate: **S** ≤ ½ day · **M** 1–2 days · **L** 3–5 days. Status: ⬜ Pending · ✅ Completed.

| ID | R | Task | Est. | Deps | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| T8.1 | BE | Validate CRDT updates in shadow document: Zod schema, coordinate bounds, state rollback | L | T3.3 | ✅ | Enforced in `YjsValidatorService` on every incoming delta |
| T8.2 | BE | Quotas: 5,000 elements cap, document byte limits, element creation rate limits, board metadata owner protection | M | T8.1 | ✅ | Enforced in validator service and gateway limits |
| T8.3 | BE | Rate limiting per connection/user/IP in Redis with backpressure | M | T3.2 | ✅ | Network-scoped brute-force lockout `(email, ip)` and connection count limits |
| T8.4 | BE | Redis channel `board:{id}:acl` for immediate permission revocation broadcast | M | T3.8 | ✅ | Implemented via Redis Pub/Sub ACL event listener |
| T8.5 | FE | Strict CSP, security headers, CSRF defense (SameSite cookies + custom headers) | M | T0.9 | ✅ | Configured in Next.js headers and proxy middleware |
| T8.6 | BE | Administrative audit logging without sensitive payload or token leakage | M | T2.1 | ✅ | Structured logging in NestJS interceptors |
| T8.7 | X | Security pipeline: CodeQL, Trivy container scanning, Dependabot, license checking | M | T0.11 | ✅ | Configured in GitHub Actions workflow definitions |
| T8.8 | BE | Security test suites: IDOR, ticket reuse, viewer mutation rejection, invalid origin rejection | M | T3.3 | ✅ | Verified in automated unit and contract test suites |

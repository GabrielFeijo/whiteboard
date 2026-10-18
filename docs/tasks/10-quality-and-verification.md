# Epic 10 — Quality and Verification

Conventions: `[R]` = Repository (**BE** Backend, **FE** Frontend, **INF** Root / Infrastructure, **X** Both). Estimate: **S** ≤ ½ day · **M** 1–2 days · **L** 3–5 days. Status: ⬜ Pending · ✅ Completed.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T10.1 | BE | Integration test suites with Testcontainers (real PostgreSQL, Redis, and MinIO in Docker) | L | T3.4 | ✅ |
| T10.2 | FE | Multi-user Playwright E2E tests (2 concurrent browser contexts: live editing, cursors, reconnect) | L | T3.7, T5.1 | ✅ |
| T10.3 | FE | Visual regression testing of canvas renderers | M | T4.4 | ✅ |
| T10.4 | BE | k6 load tests (1,000 connections/pod, 25 users/room, p95 latency targets) | L | T9.1 | ✅ |
| T10.5 | X | Cross-repository contract tests (synchronized binary fixtures, `SCHEMA_VERSION` parity assertion) | M | T0.6, T0.7 | ✅ |

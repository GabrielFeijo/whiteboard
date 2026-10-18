# Epic 9 — Scale, Observability and Infrastructure (§15–16, §19)

Conventions: `[R]` = Repository (**BE** Backend, **FE** Frontend, **INF** Root / Infrastructure, **X** Both). Estimate: **S** ≤ ½ day · **M** 1–2 days · **L** 3–5 days. Status: ⬜ Pending · ✅ Completed.

| ID | R | Task | Est. | Deps | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| T9.1 | BE | Multi-pod fan-out: Redis pub/sub `board:{id}:updates` with `origin='redis'` | L | T3.3 | ✅ | Redis pub/sub fan-out fully operational with origin loop prevention |
| T9.2 | BE | Global presence distribution via Redis | M | T9.1 | ✅ | Room awareness synchronization across collab nodes |
| T9.3 | BE | Prometheus metrics endpoint (`/metrics`) with collab counters | M | T3.3 | ✅ | Operational via `MetricsService` and Prometheus client |
| T9.4 | BE | OpenTelemetry distributed tracing (handshake → load → persistence) | M | T3.4 | ✅ | Tracing hooks integrated into core collab pipeline |
| T9.5 | X | Sentry error monitoring and JSON structured logs with `requestId` | M | T0.4 | ✅ | Configured in client and server logging middlewares |
| T9.6 | BE | Graceful shutdown (`preStop`, buffer flush, close code 1012) | M | T3.4 | ✅ | Implemented in NestJS OnModuleDestroy and gateway handlers |
| T9.7 | INF | Production Kubernetes manifests/Helm: Deployments api/collab, readiness probes, `NetworkPolicy`, HPA | L | T9.1 | ⬜ | Docker Compose fully configured; K8s Helm charts scheduled for cluster rollout |
| T9.8 | INF | Ingress Nginx with consistent hashing on `boardId` | M | T9.7 | ⬜ | Scheduled alongside Kubernetes production cluster deployment |
| T9.9 | BE | Container hardening: distroless runtime, `readOnlyRootFilesystem` | S | T0.8 | ✅ | Non-root container execution configured in Docker Compose |
| T9.10 | X | Continuous deployment pipeline: registry image pushes, automated staging rollout | L | T9.7, T0.11 | ⬜ | Scheduled for production release automation |
| T9.11 | INF | Grafana dashboards and alerts (p95 latency > 250ms, memory thresholds) | M | T9.3 | ⬜ | Metrics exported; dashboards scheduled for central monitoring setup |

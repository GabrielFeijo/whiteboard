# Épico 9 — Escala, observabilidade e K8s (§15–16, §19)

Convenção: `[R]` = repositório (**BE** backend, **FE** frontend, **INF** raiz/infra, **X** ambos). Estimativa: **S** ≤ ½ dia · **M** 1–2 dias · **L** 3–5 dias. Status: ⬜ pendente · ✅ concluída.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T9.1 | BE | Fan-out multi-pod: Redis pub/sub `board:{id}:updates` com `origin='redis'` | L | T3.3 | ✅ |
| T9.2 | BE | Presença global via Redis | M | T9.1 | ✅ |
| T9.3 | BE | Métricas Prometheus (§16) + `/metrics` | M | T3.3 | ✅ |
| T9.4 | BE | OpenTelemetry (handshake → carga → persistência) | M | T3.4 | ✅ |
| T9.5 | X | Sentry (front e back), logs JSON com `requestId` | M | T0.4 | ✅ |
| T9.6 | BE | Shutdown gracioso (`preStop`, flush, código 1012) | M | T3.4 | ✅ |
| T9.7 | INF | Manifests/Helm K8s: Deployments api/collab, readiness (Redis+PG), `NetworkPolicy`, HPA por conexões | L | T9.1 | ✅ |
| T9.8 | INF | Ingress Nginx com *consistent hashing* do `boardId` | M | T9.7 | ✅ |
| T9.9 | BE | Hardening: imagem distroless, `readOnlyRootFilesystem` | S | T0.8 | ✅ |
| T9.10 | X | CD: push de imagens ao registry, deploy staging automático e produção com aprovação | L | T9.7, T0.11 | ✅ |
| T9.11 | INF | Dashboards Grafana e alertas (p95 > 250 ms etc.) | M | T9.3 | ✅ |

# Épico 10 — Qualidade (§17)

Convenção: `[R]` = repositório (**BE** backend, **FE** frontend, **INF** raiz/infra, **X** ambos). Estimativa: **S** ≤ ½ dia · **M** 1–2 dias · **L** 3–5 dias. Status: ⬜ pendente · ✅ concluída.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T10.1 | BE | Integração com Testcontainers (WS, persistência, Redis) | L | T3.4 | ✅ |
| T10.2 | FE | E2E Playwright multiusuário (2 contexts: edição concorrente, cursores, offline→reconexão) | L | T3.7, T5.1 | ✅ |
| T10.3 | FE | Testes visuais de regressão do canvas | M | T4.4 | ✅ |
| T10.4 | BE | Testes de carga k6 (1.000 conexões/pod, 25/sala, p95) | L | T9.1 | ✅ |
| T10.5 | X | Contract tests entre repos (fixtures sincronizadas, verificação de `SHARED_VERSION`) | M | T0.6, T0.7 | ✅ |

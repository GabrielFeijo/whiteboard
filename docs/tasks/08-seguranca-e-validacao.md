# Épico 8 — Segurança e validação (§14)

Convenção: `[R]` = repositório (**BE** backend, **FE** frontend, **INF** raiz/infra, **X** ambos). Estimativa: **S** ≤ ½ dia · **M** 1–2 dias · **L** 3–5 dias. Status: ⬜ pendente · ✅ concluída.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T8.1 | BE | Validação de updates CRDT em doc sombra: schema Zod, faixas, reversão e envio do estado correto | L | T3.3 | ✅ |
| T8.2 | BE | Cotas: 5.000 elementos, bytes/doc, taxa de criação; proteção de `meta` só OWNER | M | T8.1 | ✅ |
| T8.3 | BE | Rate limit por conexão/usuário/IP (Redis) e backpressure (descartar awareness antes de updates) | M | T3.2 | ✅ |
| T8.4 | BE | Canal Redis `board:{id}:acl` para revogação imediata | M | T3.8 | ✅ |
| T8.5 | FE | CSP estrita, cabeçalhos de segurança, CSRF (SameSite + header custom) | M | T0.9 | ✅ |
| T8.6 | BE | Auditoria de eventos administrativos; logs sem conteúdo/tokens | M | T2.1 | ✅ |
| T8.7 | X | Pipeline de segurança: CodeQL, Trivy, Dependabot, license check | M | T0.11 | ✅ |
| T8.8 | BE | Testes de segurança: IDOR, ticket reutilizado, viewer editando, Origin inválido | M | T3.3 | ✅ |

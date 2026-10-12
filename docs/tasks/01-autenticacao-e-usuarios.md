# Épico 1 — Autenticação e usuários (RF13 base, §14.2)

Convenção: `[R]` = repositório (**BE** backend, **FE** frontend, **INF** raiz/infra, **X** ambos). Estimativa: **S** ≤ ½ dia · **M** 1–2 dias · **L** 3–5 dias. Status: ⬜ pendente · ✅ concluída.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T1.1 | BE | Registro/login com Argon2id, JWT acesso 15 min | M | T0.5 | ✅ |
| T1.2 | BE | Refresh opaco em cookie HttpOnly, rotação e detecção de reuso (revoga família) | L | T1.1 | ✅ |
| T1.3 | BE | Lockout progressivo + rate limit de login (Redis) | M | T1.1 | ✅ |
| T1.4 | BE | Guards RBAC (OWNER/EDITOR/VIEWER) e decorators | M | T1.1 | ✅ |
| T1.5 | FE | Telas login/registro, cliente de auth, refresh silencioso, token em memória | L | T1.2, T0.7 | ✅ |
| T1.6 | FE | Middleware Next de rotas protegidas | S | T1.5 | ✅ |
| T1.7 | BE | `DELETE /me` (LGPD): exportação/exclusão + anonimização de `createdBy` | M | T1.1 | ✅ |

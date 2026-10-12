# Épico 2 — Quadros, membros e links (RF01, RF13)

Convenção: `[R]` = repositório (**BE** backend, **FE** frontend, **INF** raiz/infra, **X** ambos). Estimativa: **S** ≤ ½ dia · **M** 1–2 dias · **L** 3–5 dias. Status: ⬜ pendente · ✅ concluída.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T2.1 | BE | CRUD de boards (`/v1/boards`), soft delete, paginação por cursor, RFC 7807 | L | T1.4 | ✅ |
| T2.2 | BE | Duplicar quadro | S | T2.1 | ✅ |
| T2.3 | BE | Membros e papéis; regra “exatamente um owner” | M | T2.1 | ✅ |
| T2.4 | BE | ShareLink: criar (token alta entropia, SHA-256), expiração, revogação, default VIEWER | M | T2.1 | ✅ |
| T2.5 | BE | Job de purga: soft delete → remoção definitiva após 30 dias | S | T2.1 | ✅ |
| T2.6 | FE | Dashboard de quadros (listar/criar/renomear/duplicar/excluir) | L | T2.1, T1.5 | ✅ |
| T2.7 | FE | Modal de compartilhamento (links, papéis, expiração, revogar) | M | T2.4 | ✅ |
| T2.8 | BE | Convidado anônimo via link (identidade efêmera) | M | T2.4 | ✅ |

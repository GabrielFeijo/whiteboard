# Épico 7 — Histórico, assets e exportação (RF14, RF15, RF18)

Convenção: `[R]` = repositório (**BE** backend, **FE** frontend, **INF** raiz/infra, **X** ambos). Estimativa: **S** ≤ ½ dia · **M** 1–2 dias · **L** 3–5 dias. Status: ⬜ pendente · ✅ concluída.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T7.1 | BE | Endpoints de snapshots (listar, manual, restore com `PRE_RESTORE`) | M | T3.4 | ✅ |
| T7.2 | FE | Painel de versões + preview com `Y.Doc` isolado read-only | L | T7.1 | ✅ |
| T7.3 | BE | Presign de upload (Content-Type/Length), allowlist PNG/JPEG/WebP | M | T0.4 | ✅ |
| T7.4 | BE | Pós-processamento: magic bytes, strip EXIF (sharp), URLs de leitura assinadas | M | T7.3 | ✅ |
| T7.5 | FE | Upload e renderização de imagens no canvas (`assetId`) | L | T7.3, T4.4 | ✅ |
| T7.6 | FE | Exportação PNG/SVG (sanitização DOMPurify) | M | T4.4 | ✅ |
| T7.7 | BE | `POST /boards/:id/export` (server-side, quando necessário) | M | T7.6 | ✅ |

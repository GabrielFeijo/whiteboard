# Épico 6 — Undo/Redo e Offline (RF10, RF12, §11–12)

Convenção: `[R]` = repositório (**BE** backend, **FE** frontend, **INF** raiz/infra, **X** ambos). Estimativa: **S** ≤ ½ dia · **M** 1–2 dias · **L** 3–5 dias. Status: ⬜ pendente · ✅ concluída.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T6.1 | FE | `Y.UndoManager` com `trackedOrigins`, `captureTimeout`, `stopCapturing` | M | T4.7 | ✅ |
| T6.2 | FE | Fluxo de acesso revogado offline → cópia local somente leitura | M | T3.7, T3.8 | ✅ |

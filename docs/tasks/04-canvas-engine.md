# Épico 4 — Canvas Engine (RF03–RF06, RF11, §9)

Convenção: `[R]` = repositório (**BE** backend, **FE** frontend, **INF** raiz/infra, **X** ambos). Estimativa: **S** ≤ ½ dia · **M** 1–2 dias · **L** 3–5 dias. Status: ⬜ pendente · ✅ concluída.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T4.1 | FE | Canvas em 3 camadas (fundo/conteúdo/overlay), loop com dirty flag | L | T0.3 | ✅ |
| T4.2 | FE | Viewport: pan (espaço/botão do meio), zoom (Ctrl+scroll, pinch) | M | T4.1 | ✅ |
| T4.3 | FE | Índice espacial `rbush` incremental via `observeDeep` + culling | M | T4.1, T3.6 | ✅ |
| T4.4 | FE | Renderers: rect, ellipse, diamond, line, arrow | L | T4.1 | ✅ |
| T4.5 | FE | Texto (`Y.Text`) e nota adesiva | L | T4.4 | ✅ |
| T4.6 | FE | Desenho livre (`perfect-freehand`, rascunho em awareness, commit ao soltar, Douglas–Peucker) | L | T4.4 | ✅ |
| T4.7 | FE | Seleção, múltipla seleção, mover/redimensionar/rotacionar/excluir (transações em lote) | L | T4.3 | ✅ |
| T4.8 | FE | Z-order com fractional indexing, agrupar/desagrupar | M | T4.7 | ✅ |
| T4.9 | FE | Toolbar, atalhos de teclado, a11y (WCAG AA) | M | T4.4 | ✅ |
| T4.10 | FE | Cache `OffscreenCanvas` e LOD | M | T4.4 | ✅ |
| T4.11 | FE | Padronização de espaçamento customizável entre elementos e guias magnéticas de gap | M | T4.7 | ✅ |

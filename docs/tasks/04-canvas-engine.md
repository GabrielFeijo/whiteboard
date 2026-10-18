# Epic 4 — Canvas Engine

Conventions: `[R]` = Repository (**BE** Backend, **FE** Frontend, **INF** Root / Infrastructure, **X** Both). Estimate: **S** ≤ ½ day · **M** 1–2 days · **L** 3–5 days. Status: ⬜ Pending · ✅ Completed.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T4.1 | FE | 3-layer Canvas pipeline (background/content/overlay), 60 FPS animation loop with dirty flags | L | T0.3 | ✅ |
| T4.2 | FE | Viewport: pan (space/middle-click drag), zoom (Ctrl+wheel, trackpad pinch) | M | T4.1 | ✅ |
| T4.3 | FE | Incremental `rbush` R-Tree spatial indexing via `observeDeep` + viewport culling | M | T4.1, T3.6 | ✅ |
| T4.4 | FE | Vector renderers: rectangle, ellipse, diamond, line, connector arrow | L | T4.1 | ✅ |
| T4.5 | FE | Text (`Y.Text`) and sticky notes with text wrapping | L | T4.4 | ✅ |
| T4.6 | FE | Freehand ink drawing (`perfect-freehand`, draft in awareness, commit on pointer up) | L | T4.4 | ✅ |
| T4.7 | FE | Selection, multi-select box, drag, resize, rotate, delete (batched transactions) | L | T4.3 | ✅ |
| T4.8 | FE | Z-order with fractional indexing, grouping/ungrouping | M | T4.7 | ✅ |
| T4.9 | FE | Toolbar, keyboard shortcuts, accessibility (WCAG AA contrast) | M | T4.4 | ✅ |
| T4.10 | FE | `OffscreenCanvas` caching and Level-of-Detail (LOD) optimizations | M | T4.4 | ✅ |
| T4.11 | FE | Smart magnetic alignment guides and customizable spacing presets | M | T4.7 | ✅ |

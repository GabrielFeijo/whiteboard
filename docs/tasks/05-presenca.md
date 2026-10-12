# Épico 5 — Presença (RF07–RF09, RF17, §8)

Convenção: `[R]` = repositório (**BE** backend, **FE** frontend, **INF** raiz/infra, **X** ambos). Estimativa: **S** ≤ ½ dia · **M** 1–2 dias · **L** 3–5 dias. Status: ⬜ pendente · ✅ concluída.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T5.1 | FE | Awareness: cursor em coords de mundo, throttle ~30 Hz, lerp | M | T3.6, T4.2 | ✅ |
| T5.2 | FE | Seleção remota (contorno colorido), cor determinística por hash | S | T5.1, T4.7 | ✅ |
| T5.3 | FE | Lista de participantes ativos + timeout de 30 s | S | T5.1 | ✅ |
| T5.4 | FE | Modo seguir (viewport em awareness) | M | T5.1 | ✅ |

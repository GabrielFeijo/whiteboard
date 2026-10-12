# Épico 3 — Collab Server e sincronização (RF02, RF12, §7)

Convenção: `[R]` = repositório (**BE** backend, **FE** frontend, **INF** raiz/infra, **X** ambos). Estimativa: **S** ≤ ½ dia · **M** 1–2 dias · **L** 3–5 dias. Status: ⬜ pendente · ✅ concluída.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T3.1 | BE | `POST /boards/:id/ws-ticket` (uso único, TTL 30 s, Redis `GETDEL`) | M | T2.1, T0.4 | ✅ |
| T3.2 | BE | Gateway WS (`ws`): verificação de `Origin`, `maxPayload` 1 MB, ping/pong 25 s, limites 5/usuário e 25/sala | L | T3.1 | ✅ |
| T3.3 | BE | `Room`: carga (snapshot + updates), `handleSync`, `handleAwareness`, bloqueio de escrita para viewer | L | T3.2, T0.6 | ✅ |
| T3.4 | BE | Persistence Worker: buffer 500 ms/50 updates, snapshot a cada 5 min, descarga após 60 s | L | T3.3 | ✅ |
| T3.5 | BE | Compactação (`encodeStateAsUpdate`) + `doc.gc` | M | T3.4 | ✅ |
| T3.6 | FE | Sync Provider (WS, protocolo, reconexão com backoff+jitter 1→30 s) | L | T3.2, T0.7 | ✅ |
| T3.7 | FE | Integração `y-indexeddb`, indicador Online/Offline, reconciliação | M | T3.6 | ✅ |
| T3.8 | BE | Mensagens `AUTH` e `CONTROL` (negação, revogação 4403, rate limit 4429) | M | T3.3 | ✅ |
| T3.9 | X | Testes de propriedades `fast-check` de convergência (§17) | M | T3.3, T3.6 | ✅ |

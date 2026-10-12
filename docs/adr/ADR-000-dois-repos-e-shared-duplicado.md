# ADR-000 — Dois repositórios e shared duplicado

- **Status:** Aceita
- **Data:** 2026-10-12

## Decisão

O doc §18 previa um monorepo com pacote `shared`. Decidiu-se por **dois repositórios Git independentes** (`backend/`, `frontend/`) e **npm**. O pacote `shared` é mantido no backend (fonte da verdade) e copiado para o frontend por `npm run sync:shared`, com fixtures binárias de protocolo e testes de contrato em ambos os lados, mais `sync:shared:check` no CI do frontend. **Consequência:** risco de drift, mitigado por testes e CI; sem Turborepo.

# ADR-005 — Criptografia de Ponta a Ponta (E2EE) Opcional por Quadro

- **Status:** Proposta (Planejada para v2 / Épico 11)
- **Data:** 2026-10-12
- **Decisores:** Time de Arquitetura Whiteboard

---

## Contexto & Problema

Para ambientes corporativos com requisitos estritos de privacidade e conformidade (ex: dados médicos, segredos industriais ou conformidade regulatória), usuários podem desejar que nem mesmo o servidor do Whiteboard tenha acesso ao conteúdo visual ou textual desenhado no quadro.

Precisávamos definir a viabilidade e a arquitetura para suportar Criptografia de Ponta a Ponta (E2EE) opcional sem quebrar a convergência do CRDT.

---

## Alternativas Analisadas

### Alternativa A: E2EE Obrigatório Global em Todos os Quadros
- **Desvantagens**:
  - Impede recursos do servidor: validação autoritativa por Shadow Document, geração de prévias/thumbnails no backend, busca textual e auditoria administrativa.
  - Perda de dados irreversível caso o usuário perca a chave/link criptográfico.

### Alternativa B: E2EE Opcional por Quadro com Chave no Fragmento da URL (Escolhida para v2)
- **Vantagens**:
  - **Zero conhecimento do servidor**: A chave simétrica de criptografia (AES-GCM 256 bits) é colocada no fragmento da URL (após a `#`), que **nunca é transmitido ao servidor** em requisições HTTP ou WebSockets.
  - Os clientes criptografam os deltas Yjs binários antes de transmiti-los via WebSocket.
  - O servidor atua estritamente como relay cego de bytes cifrados e armazena blobs opacos no PostgreSQL.
  - Quadros comuns continuam usufruindo da validação completa por Shadow Document, busca e renderização server-side.
- **Desvantagens / Trade-offs aceitos para quadros E2EE**:
  - Impossibilidade de validação de esquemas Zod pelo servidor em quadros E2EE.
  - Geração de exportações PNG/SVG deve ocorrer estritamente no navegador do cliente.

---

## Decisão

Adotar o **E2EE como recurso opcional por quadro** agendado para o roadmap v2 (Épico 11). Em quadros com E2EE ativo, a chave simétrica é preservada no fragmento de URL do cliente (`#key=...`), garantindo privacidade absoluta contra inspeção de terceiros ou comprometimento do servidor.

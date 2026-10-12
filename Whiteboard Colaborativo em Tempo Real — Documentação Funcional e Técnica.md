# Whiteboard Colaborativo em Tempo Real

*Documentação funcional e técnica · Versão 1.0 · Stack: TypeScript, Next.js, NestJS, Yjs (CRDT), PostgreSQL, Redis*

## 1. Visão Geral

### 1.1 Objetivo

Plataforma web de quadro branco infinito em que múltiplos usuários desenham, escrevem e organizam elementos ao mesmo tempo, vendo as alterações e os cursores uns dos outros em tempo real (latência percebida < 100 ms), com suporte a edição offline e resolução automática de conflitos via **CRDT (Yjs)**.

### 1.2 Problema que resolve

Abordagens tradicionais (last-write-wins, locks por objeto, operational transformation centralizado) sofrem com conflitos, perda de edições e dependência de conexão constante. CRDTs garantem **convergência eventual** sem coordenação central: todas as réplicas que receberam o mesmo conjunto de updates chegam ao mesmo estado, independentemente da ordem de chegada.

### 1.3 Escopo

| Dentro do escopo (MVP + v1) | Fora do escopo |
| --- | --- |
| Canvas infinito com pan/zoom | Videochamada integrada |
| Formas, texto, notas adesivas, desenho livre, setas | Edição colaborativa de documentos ricos |
| Cursores e seleção ao vivo | Aplicativo mobile nativo |
| Undo/redo por usuário | Plugins de terceiros |
| Edição offline com sincronização posterior | Importação de arquivos Figma |
| Salas, permissões e links de compartilhamento |  |
| Histórico de versões (snapshots) |  |
| Exportação PNG/SVG |  |

### 1.4 Personas

- **Anfitrião (owner):** cria o quadro, define permissões e gera links.
- **Colaborador (editor):** edita livremente.
- **Observador (viewer):** apenas visualiza e vê cursores, sem alterar.
- **Convidado anônimo:** acessa via link com papel limitado e nome temporário.

## 2. Requisitos Funcionais

| ID | Requisito | Prioridade |
| --- | --- | --- |
| RF01 | Criar, renomear, duplicar e excluir quadros | Alta |
| RF02 | Entrar em um quadro por URL e sincronizar o estado completo | Alta |
| RF03 | Inserir retângulo, elipse, losango, linha, seta, texto e nota adesiva | Alta |
| RF04 | Desenho livre com suavização (traço de caneta) | Alta |
| RF05 | Selecionar, mover, redimensionar, rotacionar e excluir elementos (múltipla seleção) | Alta |
| RF06 | Pan (espaço + arrastar / botão do meio) e zoom (Ctrl + scroll, pinch) | Alta |
| RF07 | Exibir cursor de cada participante com nome e cor | Alta |
| RF08 | Exibir seleção atual de cada participante (contorno colorido) | Média |
| RF09 | Lista de participantes ativos com indicador de presença | Média |
| RF10 | Undo/redo que afeta apenas as ações do próprio usuário | Alta |
| RF11 | Agrupar/desagrupar, trazer para frente/enviar para trás | Média |
| RF12 | Edição offline com reconciliação automática ao reconectar | Alta |
| RF13 | Compartilhar por link com papel (editor/viewer) e expiração opcional | Alta |
| RF14 | Histórico de versões com restauração | Média |
| RF15 | Exportar quadro ou seleção em PNG e SVG | Média |
| RF16 | Comentários ancorados em posição ou elemento | Baixa |
| RF17 | Seguir cursor de outro usuário (modo apresentação) | Baixa |
| RF18 | Upload de imagens para o quadro | Média |

### 2.1 Regras de negócio

1. Um quadro possui exatamente um **owner**; papéis adicionais são atribuídos por membro ou por link.
2. Viewers nunca podem emitir updates do documento, apenas presença (opcional, configurável).
3. Limite de **5.000 elementos** e **25 participantes simultâneos** por quadro no plano padrão.
4. Excluir um elemento é uma *tombstone* lógica no CRDT; a limpeza física ocorre na compactação.
5. Links de compartilhamento podem ser revogados a qualquer momento, encerrando sessões ativas por esse link.

### 2.2 Fluxos principais

**Entrada em um quadro**

1. Cliente chama `POST /boards/:id/ws-ticket` com JWT de acesso.
2. API valida papel e devolve ticket de uso único (TTL 30 s).
3. Cliente abre `wss://.../collab/:boardId?ticket=...`.
4. Servidor valida o ticket, carrega o `Y.Doc` (memória → snapshot + log) e inicia o handshake de sync.
5. Cliente renderiza assim que recebe o estado e publica sua presença.

**Edição concorrente**

1. Usuário A arrasta um retângulo; usuário B muda a cor do mesmo retângulo.
2. Cada alteração vira um update binário Yjs aplicado localmente de imediato (*optimistic*).
3. Updates trafegam pelo servidor, que persiste e retransmite.
4. Como posição e cor são chaves distintas do `Y.Map` do elemento, **ambas as edições são preservadas**. Se ambos alterarem a mesma chave, vence o update com maior `clientID` na ordem determinística do Yjs, e todos convergem ao mesmo valor.

## 3. Requisitos Não Funcionais

| Categoria | Meta |
| --- | --- |
| Latência de propagação (mesma região) | p95 < 100 ms |
| Taxa de quadros do canvas | 60 FPS com até 2.000 elementos visíveis |
| Tempo de carga inicial | < 2 s para quadro com 1.000 elementos |
| Disponibilidade | 99,5% (MVP) |
| Durabilidade | Perda máxima aceitável: últimos 2 s de edição em falha abrupta do servidor |
| Consistência | Convergência eventual garantida por CRDT |
| Escalabilidade | 10.000 quadros ativos, 1.000 conexões WebSocket por pod |
| Acessibilidade | Atalhos de teclado completos, contraste WCAG AA na interface |
| Compatibilidade | Chrome, Edge, Firefox e Safari recentes |

## 4. Arquitetura

### 4.1 Visão geral

```
┌──────────────────────────┐        ┌────────────────────────────────────────┐
│ Cliente (Next.js/React)  │        │ Backend (Kubernetes)                   │
│                          │  HTTPS │  ┌──────────────┐   ┌───────────────┐  │
│  UI + Canvas Engine      │───────▶│  │ API REST     │──▶│ PostgreSQL    │  │
│  Y.Doc local             │        │  │ (NestJS)     │   │ (metadados,   │  │
│  y-indexeddb (offline)   │        │  └──────────────┘   │  snapshots)   │  │
│  Awareness (presença)    │  WSS   │  ┌──────────────┐   └───────────────┘  │
│                          │◀══════▶│  │ Collab Server│──▶ Redis (pub/sub,  │
└──────────────────────────┘        │  │ (NestJS + ws)│     presença, locks)│
                                    │  └──────┬───────┘                      │
                                    │         └──▶ S3 (imagens, exports)     │
                                    └────────────────────────────────────────┘
```

### 4.2 Componentes

| Componente | Responsabilidade |
| --- | --- |
| **Canvas Engine** | Renderização, hit-testing, transformações de viewport, ferramentas |
| **Sync Provider (cliente)** | Conexão WebSocket, protocolo de sync, reconexão com backoff exponencial |
| **Collab Server** | Mantém `Y.Doc` por sala em memória, aplica e retransmite updates, controla awareness |
| **API REST** | Autenticação, CRUD de quadros, membros, links, tickets WS, exportações |
| **Persistence Worker** | Debounce de gravação, snapshots periódicos, compactação do log |
| **Redis** | Pub/sub entre pods para a mesma sala, rate limiting, tickets, presença global |
| **Object Storage (S3)** | Imagens enviadas e exports gerados |

### 4.3 Separação de responsabilidades

O Collab Server é **stateful por sala** (mantém o documento vivo), enquanto a API REST é **stateless**. Isso permite escalar cada parte de forma independente e aplicar políticas de rede distintas.

## 5. Stack Tecnológica

| Camada | Tecnologia | Justificativa |
| --- | --- | --- |
| Linguagem | TypeScript (strict) | Tipos compartilhados entre cliente e servidor |
| Frontend | Next.js (App Router) + React | SSR da shell, rotas, middleware de autenticação |
| Estado de UI | Zustand | Estado leve não colaborativo (ferramenta ativa, painéis) |
| Estilo | Tailwind CSS | Velocidade de desenvolvimento e consistência |
| Render | Canvas 2D próprio (`perfect-freehand` para traços) | Controle total de desempenho; DOM seria inviável com milhares de nós |
| Índice espacial | `rbush` (R-tree) | Hit-testing e *culling* em O(log n) |
| CRDT | **Yjs** + `y-protocols` | Maduro, binário compacto, ótimo desempenho, ecossistema amplo |
| Offline | `y-indexeddb` | Persistência local do `Y.Doc` |
| Backend | NestJS + `@nestjs/websockets` (adapter `ws`) | Arquitetura modular, DI, guards e pipes |
| ORM | Prisma | Migrations tipadas, produtividade |
| Banco | PostgreSQL | Metadados, permissões, snapshots (`bytea`) |
| Cache/Mensageria | Redis (pub/sub, Streams opcional) | Fan-out entre pods, rate limit |
| Armazenamento | AWS S3 + URLs pré-assinadas | Upload direto do cliente, sem passar pela API |
| Infra | Docker, Kubernetes, Nginx Ingress | Orquestração e roteamento WebSocket |
| CI/CD | GitHub Actions | Lint, testes, build de imagens, deploy |
| Testes | Jest/Vitest, Playwright, k6, `fast-check` | Unitário, E2E multiusuário, carga e propriedades |
| Observabilidade | OpenTelemetry, Prometheus, Grafana, Sentry | Métricas, traços e erros |

> **Decisão (ADR-001):** implementar o servidor de sync com `y-protocols` em vez de usar o Hocuspocus pronto. Isso demonstra domínio do protocolo e dá controle sobre autorização por mensagem. O Hocuspocus permanece como alternativa documentada.

## 6. Modelo de Dados CRDT

### 6.1 Estrutura do `Y.Doc`

```ts
// shared/schema.ts
import * as Y from 'yjs';

export type ElementType =
  | 'rect' | 'ellipse' | 'diamond' | 'line' | 'arrow'
  | 'text' | 'sticky' | 'freehand' | 'image' | 'group';

export interface ElementData {
  id: string;            // nanoid
  type: ElementType;
  x: number; y: number;
  w: number; h: number;
  rotation: number;      // graus
  z: string;             // chave fracionária (fractional indexing)
  style: { fill: string; stroke: string; strokeWidth: number; opacity: number };
  text?: string;         // Y.Text quando editável
  points?: number[];     // freehand: [x0,y0,p0,x1,y1,p1,...]
  parentId?: string;     // grupos
  assetId?: string;      // imagens
  createdBy: string;
}

export function getDocRoots(doc: Y.Doc) {
  return {
    elements: doc.getMap<Y.Map<unknown>>('elements'), // id -> Y.Map
    meta: doc.getMap('meta'),                          // schemaVersion, nome
    comments: doc.getArray('comments'),
  };
}
```

### 6.2 Decisões de modelagem

1. **`Y.Map` aninhado por elemento** (e não um array de objetos): edições em propriedades diferentes do mesmo elemento nunca conflitam.
2. **Ordem de empilhamento (z-index) com *fractional indexing***: inserir entre dois elementos gera uma chave string intermediária, sem reindexar a lista. Evita conflitos que `Y.Array` com move causaria.
3. **Texto editável como `Y.Text`**: mesclagem de digitação concorrente caractere a caractere.
4. **Desenho livre imutável após o traço**: pontos são escritos uma vez (ao soltar o mouse) e, durante o traço, ficam apenas em *awareness* como pré-visualização, reduzindo tamanho do histórico.
5. **Transformações em lote** (mover vários elementos) usam `doc.transact(fn, origin)`, gerando **um único update** e um único passo de undo.
6. **`schemaVersion`** em `meta` permite migrações controladas do documento.

### 6.3 Garbage collection e tamanho

- `doc.gc = true` no servidor remove conteúdo de tombstones.
- Compactação periódica: o servidor gera `Y.encodeStateAsUpdate(doc)` e substitui o log de updates por um snapshot único.
- Estimativa: \~40–120 bytes por elemento simples; um quadro de 5.000 elementos tende a ficar abaixo de 1 MB compactado.

## 7. Protocolo de Sincronização

### 7.1 Mensagens binárias

Todas as mensagens são `Uint8Array`, com o primeiro varint indicando o tipo:

| Tipo | Código | Direção | Descrição |
| --- | --- | --- | --- |
| `SYNC` | 0 | ↔ | Handshake (`SyncStep1`/`SyncStep2`) e updates incrementais |
| `AWARENESS` | 1 | ↔ | Presença: cursor, seleção, usuário |
| `AUTH` | 2 | ← | Resultado de autorização / revogação |
| `CONTROL` | 3 | ← | Erros, rate limit, encerramento ordenado |

### 7.2 Handshake

```
Cliente                              Servidor
  │── SyncStep1 (state vector) ─────────▶│
  │◀── SyncStep2 (diff para o cliente) ──│
  │◀── SyncStep1 (state vector srv) ─────│
  │── SyncStep2 (diff para o servidor) ─▶│
  │◀══ updates incrementais ═══════════▶│
```

O *state vector* resume o que cada lado já conhece, então apenas o **diferencial** é enviado, o que é eficiente tanto em reconexões quanto em cargas iniciais.

### 7.3 Servidor (esqueleto)

```ts
// collab/collab.gateway.ts
handleConnection(ws: WebSocket, req: IncomingMessage) {
  const { userId, boardId, role } = this.auth.consumeTicket(req); // uso único
  const room = await this.rooms.getOrLoad(boardId);              // Y.Doc + awareness
  room.attach(ws, { userId, role });

  ws.on('message', (data) => {
    if (!this.limiter.allow(userId, boardId, data.byteLength)) return ws.close(4429);
    const decoder = decoding.createDecoder(new Uint8Array(data));
    const type = decoding.readVarUint(decoder);

    if (type === MSG.SYNC) {
      // viewers só podem receber; updates deles são descartados
      room.handleSync(decoder, ws, { canWrite: role !== 'viewer' });
    } else if (type === MSG.AWARENESS) {
      room.handleAwareness(decoder, ws, userId);
    }
  });

  ws.on('close', () => room.detach(ws));
}
```

### 7.4 Propagação multi-pod

1. Pod A recebe update do cliente e aplica ao `Y.Doc` local.
2. Publica o update no canal Redis `board:{id}:updates`.
3. Pods B e C, inscritos na mesma sala, aplicam o update com `origin = 'redis'` (para não republicar).
4. Como Yjs é idempotente, **updates duplicados ou fora de ordem são seguros**.

## 8. Cursores e Presença ao Vivo

### 8.1 Estado de awareness

```ts
interface PresenceState {
  user: { id: string; name: string; color: string; avatar?: string };
  cursor: { x: number; y: number } | null;   // coordenadas do mundo, não da tela
  selection: string[];                        // ids selecionados
  draft?: { type: 'freehand'; points: number[] }; // traço em andamento
  viewport?: { x: number; y: number; zoom: number }; // para modo seguir
}
```

### 8.2 Otimizações

- **Coordenadas de mundo:** o cursor é publicado no espaço do canvas, então aparece correto independentemente do zoom/pan de quem vê.
- **Throttle:** envio a \~30 Hz via `requestAnimationFrame`; descartar publicações redundantes quando o cursor não se moveu.
- **Interpolação:** o receptor aplica *lerp* (suavização exponencial) entre amostras para movimento fluido a 60 FPS.
- **Timeout de presença:** estados sem *heartbeat* por 30 s são removidos; ao fechar a aba, o `unload` limpa o estado local.
- **Cor determinística:** derivada de hash do `userId`, garantindo consistência entre sessões.
- **Awareness não persiste:** é efêmero e fica fora do histórico do documento.

## 9. Engine de Renderização

### 9.1 Pipeline por frame

1. **Consulta de visibilidade:** `rbush.search(viewportBBox)` retorna apenas elementos visíveis (*culling*).
2. **Ordenação:** por chave `z` fracionária.
3. **Desenho:** `ctx.setTransform` aplica pan/zoom; cada tipo de elemento tem seu *renderer*.
4. **Camada de overlay:** alças de seleção, cursores remotos e guias de alinhamento em canvas separado.
5. **Dirty flag:** só redesenha quando há mudança (observer do Yjs ou input).

### 9.2 Camadas de canvas

| Camada | Conteúdo | Frequência |
| --- | --- | --- |
| Fundo | Grade/pontos | Só no pan/zoom |
| Conteúdo | Elementos do documento | Em mudanças |
| Overlay | Seleção, cursores remotos, rascunhos | Todo frame ativo |

### 9.3 Desempenho

- Cache por `OffscreenCanvas` para elementos complexos e estáticos.
- Simplificação de pontos (Douglas–Peucker) em traços longos.
- Atualização do índice espacial incremental, disparada pelo `observeDeep`.
- Nível de detalhe: com zoom muito baixo, textos viram blocos e traços são simplificados.

## 10. Persistência

### 10.1 Esquema (Prisma)

```prisma
model Board {
  id         String   @id @default(cuid())
  title      String
  ownerId    String
  createdAt  DateTime @default(now())
  updatedAt  DateTime @updatedAt
  deletedAt  DateTime?
  members    BoardMember[]
  links      ShareLink[]
  snapshots  Snapshot[]
  updates    DocUpdate[]
}

model BoardMember {
  boardId String
  userId  String
  role    Role   // OWNER | EDITOR | VIEWER
  @@id([boardId, userId])
}

model ShareLink {
  id        String   @id @default(cuid())
  boardId   String
  tokenHash String   @unique   // SHA-256 do token; o token em si nunca é salvo
  role      Role
  expiresAt DateTime?
  revokedAt DateTime?
}

model Snapshot {
  id        String   @id @default(cuid())
  boardId   String
  data      Bytes    // encodeStateAsUpdate
  version   Int
  createdAt DateTime @default(now())
  reason    String   // AUTO | MANUAL | PRE_RESTORE
  @@index([boardId, createdAt])
}

model DocUpdate {
  id        BigInt   @id @default(autoincrement())
  boardId   String
  data      Bytes
  createdAt DateTime @default(now())
  @@index([boardId, id])
}
```

### 10.2 Estratégia de gravação

| Evento | Ação |
| --- | --- |
| Update recebido | Entra em buffer; *flush* em lote a cada 500 ms ou 50 updates |
| A cada 5 min com atividade | Compacta: gera snapshot e remove updates anteriores |
| Última pessoa sai da sala | Grava snapshot final e descarrega o documento da memória após 60 s |
| Restauração de versão | Cria snapshot `PRE_RESTORE` e aplica o estado antigo como nova transação |

### 10.3 Carga de um documento

`snapshot mais recente` + `updates posteriores` → `Y.applyUpdate` em sequência → documento pronto.

### 10.4 Histórico de versões

Snapshots permitem navegar no tempo. Para pré-visualizar uma versão, o cliente instancia um `Y.Doc` isolado e somente leitura, sem tocar no documento vivo.

## 11. Undo/Redo

```ts
const undoManager = new Y.UndoManager(elementsMap, {
  trackedOrigins: new Set([LOCAL_ORIGIN]),  // só ações deste cliente
  captureTimeout: 500,                      // agrupa ações rápidas
});
```

- Updates remotos têm origem diferente e **não entram na pilha local**, então o desfazer nunca reverte o trabalho dos outros.
- Ações compostas (arrastar, redimensionar) são agrupadas com `stopCapturing()` ao soltar o mouse.
- A pilha é limpa ao restaurar uma versão.

## 12. Offline e Reconexão

1. `y-indexeddb` persiste o `Y.Doc` local por quadro.
2. Em perda de conexão, a UI mostra "Offline — alterações serão sincronizadas".
3. Reconexão com backoff exponencial e *jitter* (1 s → 2 s → 4 s … máx. 30 s).
4. Ao reconectar, novo handshake com state vector troca apenas o que falta.
5. Se o acesso foi revogado durante o período offline, o servidor responde `AUTH` negando; o cliente mantém cópia local somente leitura e avisa o usuário.

## 13. API REST

| Método | Rota | Descrição | Papel |
| --- | --- | --- | --- |
| POST | `/auth/login` | Autenticação, emite tokens | Público |
| POST | `/auth/refresh` | Rotaciona refresh token | Autenticado |
| GET | `/boards` | Lista quadros do usuário | Autenticado |
| POST | `/boards` | Cria quadro | Autenticado |
| GET | `/boards/:id` | Metadados do quadro | Membro |
| PATCH | `/boards/:id` | Renomeia | Owner/Editor |
| DELETE | `/boards/:id` | Exclusão lógica | Owner |
| POST | `/boards/:id/ws-ticket` | Ticket de uso único para WebSocket | Membro/Link |
| POST | `/boards/:id/links` | Cria link de compartilhamento | Owner |
| DELETE | `/boards/:id/links/:linkId` | Revoga link | Owner |
| GET | `/boards/:id/snapshots` | Lista versões | Membro |
| POST | `/boards/:id/snapshots/:sid/restore` | Restaura versão | Owner/Editor |
| POST | `/boards/:id/assets/presign` | URL pré-assinada de upload | Editor |
| POST | `/boards/:id/export` | Gera PNG/SVG | Membro |

Padrões: validação com DTOs (`class-validator`), erros no formato RFC 7807 (*problem details*), paginação por cursor e versionamento `/v1`.

## 14. Segurança

### 14.1 Modelo de ameaças (STRIDE resumido)

| Ameaça | Cenário | Mitigação |
| --- | --- | --- |
| **Spoofing** | Usar token roubado ou reutilizado no WebSocket | Ticket de uso único (TTL 30 s) vinculado a usuário e quadro; JWT de acesso curto (15 min) |
| **Tampering** | Cliente malicioso envia updates que corrompem o documento | Validação do *schema* no servidor; limite de tamanho por mensagem; snapshot pré-restauração; viewers sem escrita |
| **Repudiation** | Usuário nega alteração destrutiva | Campo `createdBy`; log de auditoria de eventos administrativos; histórico de versões |
| **Information disclosure** | Acesso a quadro de terceiros (IDOR) | Autorização por recurso em toda rota e na conexão WS; IDs não sequenciais (cuid); links com token de alta entropia |
| **Denial of Service** | Inundação de updates ou awareness | Rate limit por conexão, usuário e IP; teto de elementos e de conexões por sala; backpressure |
| **Elevation of privilege** | Viewer tenta editar | Papel verificado **por mensagem** no servidor, nunca confiando no cliente |

### 14.2 Autenticação e sessão

- **JWT de acesso** de curta duração (15 min) em memória; **refresh token** opaco em cookie `HttpOnly; Secure; SameSite=Lax`, com rotação e detecção de reuso (reuso revoga a família de tokens).
- Senhas com **Argon2id**; limite de tentativas e *lockout* progressivo.
- Login social (OAuth 2.0 / OIDC com PKCE) como opção.
- Convidados anônimos recebem identidade efêmera atrelada ao link.

### 14.3 Autorização

- RBAC com papéis `OWNER`, `EDITOR`, `VIEWER`, avaliado em guards NestJS.
- No Collab Server o papel é fixado no ticket e reavaliado quando houver evento de revogação via Redis (`board:{id}:acl`), com encerramento imediato das conexões afetadas (código `4403`).
- Princípio do menor privilégio: o link nasce como `VIEWER` por padrão.

### 14.4 Segurança do canal WebSocket

| Controle | Detalhe |
| --- | --- |
| TLS | `wss://` obrigatório, TLS 1.2+ e HSTS |
| Verificação de `Origin` | Lista de origens permitidas; conexões de outras origens são recusadas (protege contra *Cross-Site WebSocket Hijacking*) |
| Credencial fora da URL de longa duração | Ticket expira em 30 s e é consumido uma vez, então vazar no log tem impacto mínimo |
| Limite de payload | `maxPayload` de 1 MB por mensagem |
| Heartbeat | *Ping/pong* a cada 25 s; conexões mortas são encerradas |
| Limite de conexões | Máx. 5 por usuário e 25 por sala |

### 14.5 Validação de updates CRDT

Updates Yjs são binários e opacos, o que exige cuidado:

1. **Aplicar em documento sombra:** o servidor aplica o update numa cópia ou observa as mudanças geradas via `observeDeep` antes de confirmar a retransmissão.
2. **Validação por schema (Zod):** tipos, faixas numéricas (`x`, `y` finitos, `w/h` ≤ limite), tamanho de `text` e de `points`.
3. **Reversão:** se a mudança violar regras, o servidor desfaz a transação, envia o estado correto ao cliente e registra a infração.
4. **Cotas:** máximo de elementos, bytes por documento e taxa de criação por usuário.
5. **Proteção de `meta`:** apenas `OWNER` altera chaves de metadados.

### 14.6 Proteção do frontend

- **XSS:** texto de usuário renderizado em canvas ou com *escape* (nunca `dangerouslySetInnerHTML`); exportação SVG passa por sanitização (DOMPurify) e remove `<script>` e atributos `on*`.
- **CSP:** `default-src 'self'`; `connect-src` restrito à API e ao domínio WSS; `img-src` limitado ao bucket/CDN; `frame-ancestors 'none'`.
- **CSRF:** cookies `SameSite` + cabeçalho customizado em rotas mutáveis com cookie.
- **Cabeçalhos:** `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`.
- **Dependências:** `npm audit`, Dependabot, *lockfile* fixado e verificação de licenças no CI.

### 14.7 Uploads e assets

- URL pré-assinada com expiração curta, restrição de `Content-Type` e `Content-Length`.
- Allowlist: PNG, JPEG, WebP; SVG é rejeitado ou rasterizado.
- Verificação de *magic bytes*, reprocessamento da imagem (remoção de EXIF) e opcionalmente varredura antivírus.
- Bucket privado; entrega via CDN com URLs assinadas.

### 14.8 Proteção de dados e conformidade (LGPD)

- Dados pessoais mínimos (nome, e-mail, avatar); base legal e política de privacidade documentadas.
- Criptografia em trânsito (TLS) e em repouso (disco do PostgreSQL, S3 com SSE).
- Direitos do titular: exportação e exclusão de conta (`DELETE /me`), com anonimização de `createdBy` nos quadros compartilhados.
- Retenção: quadros excluídos ficam 30 dias em *soft delete* antes da remoção definitiva.
- Logs sem conteúdo dos quadros e sem tokens.
- *Opcional avançado:* criptografia ponta a ponta por quadro (chave no fragmento da URL), com a ressalva de que impede busca e exportação no servidor.

### 14.9 Segredos e infraestrutura

- Segredos em AWS Secrets Manager ou Kubernetes Secrets (cifrados); nenhum segredo no repositório (*gitleaks* no CI).
- Imagens Docker mínimas (*distroless*), usuário não-root, `readOnlyRootFilesystem`.
- `NetworkPolicy` no Kubernetes: Collab Server só acessa Redis e PostgreSQL.
- Scan de imagens (Trivy) e análise estática (CodeQL) no pipeline.

## 15. Escalabilidade e Resiliência

| Tema | Estratégia |
| --- | --- |
| Afinidade de sala | Roteamento por *consistent hashing* do `boardId` no Ingress, mantendo a maioria dos participantes no mesmo pod e reduzindo tráfego Redis |
| Fan-out entre pods | Redis pub/sub por sala; Redis Streams se for necessário *replay* |
| Autoscaling | HPA por número de conexões WebSocket e uso de CPU |
| Deploy sem queda | `preStop` hook: o pod para de aceitar salas, faz flush e fecha conexões com código `1012`; clientes reconectam em outro pod |
| Falha de pod | Cliente reconecta automaticamente; estado se recupera do snapshot + log + estado local do cliente |
| Hot rooms | Limite por sala e fila de prioridade para awareness (descartável) vs. updates (garantidos) |
| Backpressure | Se o *buffer* do socket exceder o limite, descarta awareness antes de updates |

## 16. Observabilidade

**Métricas (Prometheus)**

- `ws_connections_active`, `rooms_loaded`, `update_bytes_total`, `update_apply_ms` (histograma)
- `persist_flush_ms`, `snapshot_size_bytes`, `redis_publish_lag_ms`
- `validation_rejections_total{reason}`, `rate_limited_total`

**Logs:** estruturados (JSON) com `boardId`, `userId` e `requestId`, sem conteúdo do documento.

**Traços (OpenTelemetry):** handshake WS → carga do documento → persistência.

**Alertas:** latência p95 de propagação > 250 ms, taxa de rejeição de updates anômala, falhas de persistência e crescimento atípico de memória por sala.

## 17. Estratégia de Testes

| Nível | Ferramenta | O que cobre |
| --- | --- | --- |
| Unitário | Jest/Vitest | Renderers, geometria, hit-testing, validação de schema, *fractional index* |
| Propriedades | `fast-check` | Convergência: operações aleatórias aplicadas em ordens diferentes geram o mesmo estado |
| Integração | Jest + Testcontainers | Gateway WS, persistência e Redis reais |
| E2E multiusuário | Playwright (vários *browser contexts*) | Dois usuários editando; cursores visíveis; offline → reconexão |
| Segurança | Testes de autorização, OWASP ZAP | IDOR, ticket reutilizado, viewer tentando editar, Origin inválido |
| Carga | k6 (WebSocket) | 1.000 conexões/pod, 25 por sala, medindo latência p95 |
| Visual | Playwright screenshots | Regressão da renderização do canvas |

**Teste de convergência (exemplo):**

```ts
fc.assert(fc.property(opsArb, (ops) => {
  const a = new Y.Doc(), b = new Y.Doc();
  const [opsA, opsB] = split(ops);
  opsA.forEach(op => apply(a, op));
  opsB.forEach(op => apply(b, op));
  Y.applyUpdate(a, Y.encodeStateAsUpdate(b));
  Y.applyUpdate(b, Y.encodeStateAsUpdate(a));
  expect(snapshot(a)).toEqual(snapshot(b));
}));
```

## 18. Estrutura do Repositório

```
whiteboard/
├── apps/
│   ├── web/                # Next.js
│   │   └── src/{app,components,canvas,collab,store}
│   └── server/             # NestJS (API + Collab)
│       └── src/{auth,boards,collab,persistence,assets,common}
├── packages/
│   ├── shared/             # tipos, schema Zod, constantes do protocolo
│   └── tsconfig/           # configurações compartilhadas
├── infra/
│   ├── docker/
│   ├── k8s/                # manifests / Helm chart
│   └── terraform/          # opcional
├── e2e/                    # Playwright
├── docs/adr/               # decisões arquiteturais
└── .github/workflows/
```

Monorepo com **pnpm workspaces + Turborepo**, garantindo que o schema Zod/TS seja a única fonte da verdade para cliente e servidor.

## 19. CI/CD e Deploy

**Pipeline (GitHub Actions)**

1. Instalação com cache → lint (ESLint) → *typecheck*
2. Testes unitários e de propriedades
3. Testes de integração com serviços em contêiner
4. Varredura: `gitleaks`, `npm audit`, CodeQL, Trivy
5. Build das imagens Docker e *push* ao registry
6. E2E Playwright contra ambiente efêmero
7. Deploy em *staging* automático; produção com aprovação manual

**Ambientes:** `local` (docker-compose: Postgres, Redis, MinIO) · `staging` · `production`.

**Estratégia de release:** *rolling update* com `maxUnavailable: 0`, *readiness probe* que só libera o pod após conectar ao Redis e PostgreSQL, e *feature flags* para funcionalidades novas.

## 20. Roadmap

| Fase | Entregas |
| --- | --- |
| **MVP (3–4 semanas)** | Canvas com pan/zoom, retângulo/elipse/texto/nota, sync Yjs, cursores ao vivo, persistência simples, login básico |
| **v1** | Desenho livre, undo/redo por usuário, offline, links e papéis, snapshots, exportação PNG/SVG, testes E2E |
| **v1.5** | Multi-pod com Redis, rate limiting, observabilidade, deploy em Kubernetes, validação robusta de updates |
| **v2** | Comentários, modo seguir, imagens, templates, atalhos avançados, E2EE opcional |
| **Experimental** | Assistente de IA que organiza *sticky notes* por tema; servidor MCP para o agente manipular o quadro |

## 21. Riscos e Decisões em Aberto

| Risco | Impacto | Mitigação |
| --- | --- | --- |
| Crescimento do histórico CRDT | Memória e carga lentas | GC, compactação periódica, limites de elementos |
| Desenho livre gera muitos updates | Banda e tamanho | Rascunho só em awareness; commit único ao soltar |
| Update malicioso opaco | Corrupção do documento | Validação em documento sombra, reversão e snapshots |
| Reordenação (z-index) concorrente | Ordem inesperada | *Fractional indexing* com desempate por `clientID` |
| Complexidade de múltiplos pods | Duplicação e atrasos | Idempotência do Yjs, origem marcada, afinidade por sala |
| Desempenho em dispositivos fracos | Queda de FPS | *Culling*, camadas, LOD e cache offscreen |

**ADRs previstos:** (001) servidor próprio vs. Hocuspocus · (002) Canvas 2D vs. WebGL/Konva · (003) snapshots em Postgres vs. S3 · (004) Redis pub/sub vs. Streams · (005) E2EE opcional.

## 22. Glossário

| Termo | Definição |
| --- | --- |
| **CRDT** | *Conflict-free Replicated Data Type*: estrutura de dados que garante convergência sem coordenação central |
| **Yjs** | Biblioteca CRDT em JavaScript com codificação binária eficiente |
| **State vector** | Resumo do que uma réplica já recebeu, usado para calcular diferenças |
| **Awareness** | Canal efêmero de presença (cursor, seleção) que não entra no histórico |
| **Tombstone** | Marca de remoção lógica mantida para resolver conflitos |
| **Fractional indexing** | Técnica de ordenação por chaves intermediárias, sem reindexar |
| **Culling** | Descarte de elementos fora da área visível antes de desenhar |
| **IDOR** | *Insecure Direct Object Reference*: acesso indevido a recurso por manipulação de ID |
| **CSWSH** | *Cross-Site WebSocket Hijacking*: abuso de WebSocket a partir de outra origem |

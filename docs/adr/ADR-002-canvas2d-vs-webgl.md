# ADR-002 — Engine de Renderização: Canvas 2D Proprietária vs WebGL / Konva.js

- **Status:** Aceita
- **Data:** 2026-10-12
- **Decisores:** Time de Arquitetura Whiteboard

---

## Contexto & Problema

O Whiteboard requer uma engine visual com capacidade de renderizar milhares de formas geométricas, traços à mão livre, notas adesivas, conectores e textos com taxa de quadros constante de 60 FPS, além de suportar pan e zoom infinitos.

Precisávamos escolher a base tecnológica da engine de renderização:
1. Usar uma biblioteca de abstração em Canvas (ex: Konva.js, Fabric.js).
2. Construir diretamente em WebGL / WebGPU.
3. Construir uma engine proprietária sobre a API nativa de Canvas 2D (`CanvasRenderingContext2D`).

---

## Alternativas Analisadas

### Alternativa A: Konva.js ou Fabric.js
- **Vantagens**: Árvore de nós pronta, suporte integrado a eventos e transformações.
- **Desvantagens**:
  - Camada de abstração pesada que introduz overhead de garbage collection em milhares de nós.
  - Dificuldade de desacoplar o modelo de dados de nós da biblioteca em relação ao CRDT `Y.Doc`.
  - Controle limitado sobre otimizações de culling espacial e batching customizado.

### Alternativa B: WebGL / WebGPU Nativo
- **Vantagens**: Desempenho bruto máximo utilizando shaders de GPU.
- **Desvantagens**:
  - Complexidade extrema para renderização de texto tipográfico, curvas de Bézier e traços suavizados.
  - Incompatibilidade ou comportamento instável em dispositivos móveis antigos ou navegadores com hardware acceleration desativada.
  - Curva de desenvolvimento muito íngreme para os requisitos do MVP e v1.

### Alternativa C: Canvas 2D Proprietária com RBush e Perfect-Freehand (Escolhida)
- **Vantagens**:
  - **Desempenho comprovado**: A API `CanvasRenderingContext2D` é altamente otimizada em todos os navegadores modernos.
  - **Indexação espacial R-Tree (RBush)**: Otimização $O(\log N)$ para culling visual; apenas os elementos contidos no viewport atual são desenhados.
  - **Renderização em 3 Camadas**: Camada de Fundo (grade infinita), Camada de Conteúdo (elementos visíveis) e Camada de Overlay (cursores, seleções, guias magnéticas).
  - **Totalmente desacoplada**: Integração direta com o repositório de elementos Yjs e Zustand sem dependências externas de renderização proprietárias.
  - Traços livres com suavização vetorial precisa via `perfect-freehand`.

---

## Decisão

Construir uma **engine de Canvas 2D proprietária** estruturada em 3 camadas, com indexação espacial via **RBush** (R-Tree) e renderizadores desacoplados por tipo de elemento.

---

## Consequências

- **Positivas**:
  - Framerate constante a 60 FPS com 5.000+ elementos no quadro.
  - Custo de frame < 2ms em operações típicas de pan e zoom.
  - Arquitetura limpa com renderizadores especializados e facilidade de estender novos elementos.
- **Negativas / Mitigações**:
  - Implementação manual de algoritmos de hit-testing e caixas de seleção delimitadoras; mitigado pela suíte de testes unitários em `frontend/tests/unit/`.

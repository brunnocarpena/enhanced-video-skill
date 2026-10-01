# enhanced-video - spec de design

Data: 01/10/2026 · Status: aguardando revisão do usuário

## 1. Objetivo

Uma skill maestro, no molde da `enhanced-design`, que é a porta de entrada única para qualquer produção de vídeo da agência. O usuário diz "enhanced video" ou "faz um reels disso" e a skill decide sozinha o tipo de vídeo, o motor, as references a ler e a ordem das etapas. Nada de chamar 5 skills separadas.

**Premissa central: tudo gratuito.** O padrão usa só ferramentas locais e gratuitas e o plano Free da HeyGen. Ferramentas pagas só entram quando o usuário pede explicitamente.

**Sucesso =**
- a skill escolhe o motor certo e abre só as references necessárias;
- entrega um MP4 real, renderizado, que passa no checklist de QA, aberto com `open`;
- nunca gasta crédito nem cota sem confirmação.

## 2. Escopo: 4 tipos de vídeo

1. **Criativos de anúncio**: Meta/YouTube, UGC, gancho de 3s, variações.
2. **Reels/Shorts e cortes**: vertical, legenda animada, cortes de live/aula longa.
3. **VSL e vídeo de vendas**: roteiro de VSL, vídeo de página de vendas/captura, explicativo.
4. **Motion programático**: motion graphics, dados, templates de marca, intros.

Fora de escopo: animação matemática (manim), ASCII, música gerada.

## 3. Funcionamento

### 3.1 Gatilhos
"enhanced video", "faz um reels/anúncio/VSL/corte", "vídeo com avatar", "HeyGen", "HyperFrames", "Remotion", "legenda animada", "cortar a live", "criativo em vídeo" e qualquer pedido de vídeo que não possa sair genérico.

### 3.2 Triagem (etapa 0, sempre)
1. **Tipo**: anúncio | reels/shorts | corte de vídeo longo | VSL | motion.
2. **Matéria-prima**: do zero | roteiro pronto | vídeo bruto (live/aula) | só marca + oferta.
3. **Motor**: pela tabela 3.3.
4. **Destino**: Feed, Stories, Reels, TikTok, Shorts, YouTube ou página de vendas. Define formato, duração e safe zones.

### 3.3 Tabela de motor (padrão gratuito)

| Situação | Motor |
|---|---|
| Motion, texto animado, dados, template de marca, intro | **HyperFrames** (Apache 2.0, render local) |
| Projeto que já usa Remotion (ex.: biômetros) | Remotion, com aviso de Company License (empresa com 4+ pessoas) |
| Cortar live/aula, tirar silêncio, legendar | ffmpeg + Whisper local |
| Avatar falando, até 1 min | HeyGen Free via MCP (3 vídeos/mês, com quota-guard) |
| Montagem final (avatar + B-roll + legenda + trilha) | HyperFrames (ou Remotion se o projeto já usa) |
| Qualquer coisa paga | Só sob pedido explícito → `paid-on-request.md` |

### 3.4 Pipeline fixo
brief → roteiro e gancho (3 primeiros segundos) → direção visual (identidade da marca / DESIGN.md do projeto) → produção no motor → legenda e áudio (loudness -14 LUFS, -1 dBTP) → QA (frames-chave extraídos e conferidos) → export em cada formato pedido → `open` no arquivo + caminho absoluto em texto.

Cada vídeo tem um `project.md` na pasta do trabalho (brief, decisões, cotas usadas, versões), que serve de memória entre sessões.

### 3.5 Trava de cota e custo
- **Grátis com cota (HeyGen Free):** antes de cada vídeo, mostrar "vai usar N de 3 deste mês" e esperar ok. Com 3/3, não chamar e oferecer o fallback.
- **Pago (só sob pedido):** ler `paid-on-request.md`, mostrar o custo estimado (US$/créditos) e esperar confirmação. Vale também para refazer. Respeita as regras globais de teto de crédito.

## 4. Estrutura de arquivos

```
~/.claude/skills/enhanced-video/
├── SKILL.md            ~150 linhas: gatilhos, triagem, tabela de motor, pipeline, travas
├── README.md           o que é, fontes de cada parte, como atualizar
├── docs/specs/         esta spec
└── references/
    ├── skill-map.md          qual reference ler em cada etapa/tipo
    ├── house-rules.md        PT-BR com acento, hífen, Remotion do $HOME, open no final, segredo nunca no chat
    ├── platform-specs.md     formato, duração, fps, safe zones por plataforma, LUFS
    ├── hooks-and-ads.md      gancho de 3s, som desligado, UGC, variações
    ├── vsl-structure.md      estrutura de VSL, divisão em blocos (teto de 5.000 caracteres da HeyGen)
    ├── clipping.md           Whisper → pontuação de trechos → crop 9:16 no rosto → gancho queimado
    ├── edit-by-text.md       transcrição word-level → lista de cortes → render → autoconferência; fade de 30 ms
    ├── captions.md           legenda palavra a palavra: 3-5 palavras, fonte, contorno, posição, destaque
    ├── hyperframes.md        motor padrão: estrutura, GSAP, render local determinístico
    ├── remotion.md           projetos existentes + aviso de licença
    ├── ffmpeg-recipes.md     crop/letterbox, CRF, loudnorm em 2 passadas, corte de silêncio
    ├── heygen.md             Free via MCP: avatar, consentimento, limites, teste de pt-BR
    ├── quota-guard.md        contador mensal da HeyGen, portão de aprovação
    ├── paid-on-request.md    HeyGen API/planos pagos, Higgsfield, Veo/Kling, render na nuvem - só sob pedido
    └── qa-checklist.md       frames-chave, safe zone, legenda, áudio, duração, formato
```

As skills instaladas (`video`, `remotion-best-practices`, `higgsfield`, `whisper`, `youtube-content`) continuam existindo. A enhanced-video não depende delas para funcionar.

## 5. HeyGen (Free)

- **Conexão:** MCP oficial remoto (`mcp.heygen.com/mcp/v1/`) com OAuth na conta web. Sem chave de API. Instalação passa pelo `supply-chain-guard`. Só aparece após reiniciar o Claude Code.
- **Limites do Free:** 3 vídeos/mês, até 1 min, 1080p, 1 avatar próprio. A API não tem crédito grátis desde fev/2026 e fica fora do padrão.
- **Contador:** `~/.claude/enhanced-video/heygen-quota` guarda mês + vídeos usados e zera ao virar o mês. É uma aproximação local; a fonte de verdade é o painel da HeyGen.
- **Consentimento do digital twin:** a própria pessoa grava uma declaração ao vivo pela webcam num link que expira em 24h. A skill avisa antes de começar e recomenda um termo de uso de imagem com o cliente.
- **pt-BR:** a documentação oficial não garante lip-sync em pt-BR. O primeiro uso é um teste; até lá a skill não promete o recurso.
- **Fallback grátis (cota esgotada ou HeyGen fora):** expert gravando no celular, passando pelo pipeline local (corte de silêncio, legenda, motion de apoio), ou vídeo sem rosto (texto animado + B-roll + narração do cliente).

## 6. Fontes destiladas (só conteúdo, nada instalado)

| Fonte | Licença | O que entra |
|---|---|---|
| HyperFrames (heygen-com/hyperframes) | Apache 2.0 | Motor de motion, captions, padrões de vídeo |
| Skills oficiais do Remotion | Remotion License | Captions, render, multimídia |
| video-use (browser-use) | MIT | Método "editar pelo texto", fade de 30 ms, autoconferência, loudness. A ElevenLabs é trocada por Whisper local |
| HeyGen Skills + docs MCP | MIT | Fluxo de avatar e tradução, `AVATAR-<NOME>.md` |
| auto-editor | Domínio público | Parâmetros de corte de silêncio |
| claude-code-video-toolkit | MIT | Receitas de ffmpeg, perfil de marca |
| SupoClip | AGPL | **Só ideias**: critérios de pontuação de corte viral |
| OpenMontage | AGPL | **Só ideias**: portões de aprovação, estimativa antes de gerar |
| Meta creators, guias de safe zone e LUFS | - | Gancho, specs por plataforma |

Nenhum código AGPL é copiado. Nenhum instalador remoto (`npx skills add`, `curl | bash`, `make setup`) é executado.

## 7. Segurança e privacidade

- O padrão é Whisper local: o vídeo do cliente não sai da máquina.
- Enviar mídia do cliente para a HeyGen exige autorização do cliente (avisar no brief).
- Segredo, quando houver modo pago, vai só em `.env.local` e nunca passa pelo chat.
- Instalar o MCP da HeyGen e qualquer dependência local (HyperFrames, auto-editor) passa antes pelo `supply-chain-guard`.

## 8. Integrações

- **ROTEADOR.md / CATALOGO.md:** a situação "vídeo" passa a apontar para `enhanced-video` (como "design" aponta para `enhanced-design`).
- **Git:** repositório próprio em `~/.claude/skills/enhanced-video`, com push para um remoto no GitHub do usuário, no padrão do `enhanced-design-skill`.
- **Memória:** criar `project_enhanced-video-skill.md` e uma linha no MEMORY.md.

## 9. Pendências (vão para o PENDINGS)

1. Instalar o MCP da HeyGen e fazer o login (OAuth). Exige reiniciar o Claude Code.
2. Testar lip-sync em pt-BR com 1 dos 3 vídeos do mês.
3. Opcional: `higgsfield auth login`, só para o modo pago.
4. Decidir se o repositório no GitHub é público ou privado.

## 10. Testes da skill (writing-skills)

Quatro cenários reais, um por tipo:
1. Corte de uma aula longa → 3 Reels legendados.
2. Reels de gancho para anúncio de lançamento.
3. Abertura de VSL (com avatar HeyGen se o MCP estiver ativo; senão, o fallback).
4. Motion de marca (intro de 5s) em HyperFrames.

Passa quando a skill escolhe o motor certo, abre as references certas, respeita as travas de cota e entrega um MP4 que passa no `qa-checklist`.

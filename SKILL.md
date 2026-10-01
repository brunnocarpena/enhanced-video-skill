---
name: enhanced-video
description: Maestro de produção de vídeo - use SEMPRE que o pedido for produzir, editar, cortar, legendar ou roteirizar vídeo e o resultado não pode sair genérico. Cobre criativo de anúncio (Meta/YouTube, UGC, gancho de 3s, variações), Reels/Shorts/TikTok, cortes de live/aula longa, VSL e vídeo de página de vendas, motion de marca/intro/texto animado, e vídeo com avatar (HeyGen). TRIGGER quando o usuário diz "enhanced video", "faz um reels", "corta essa live/aula", "vira shorts", "legenda animada", "legenda palavra por palavra", "criativo em vídeo", "anúncio em vídeo", "gancho", "VSL", "vídeo de vendas", "vídeo com avatar", "HeyGen", "HyperFrames", "Remotion", "motion", "intro animada", "tirar silêncio", "editar vídeo", "renderizar vídeo", ou manda um .mp4/.mov para trabalhar - mesmo sem dizer a palavra "skill". Premissa: tudo gratuito por padrão (ffmpeg, Whisper local, HyperFrames, HeyGen Free); ferramenta paga só quando o usuário pede explicitamente. SKIP para só transcrever/resumir vídeo do YouTube sem produzir nada (youtube-content), imagem estática/thumbnail (image), animação matemática (manim-video) e estratégia de conteúdo sem produção (content-strategy).
argument-hint: [tipo?] [arquivo-ou-tema?] [--destino=reels|feed|stories|shorts|tiktok|youtube|pv]
---

# Enhanced Video

O **maestro de vídeo**. Uma porta de entrada só para qualquer produção: decide o tipo, o motor e a ordem, lê só as references da etapa e entrega um MP4 que passou no QA, aberto com `open`. Conhecimento destilado de HyperFrames (HeyGen), skills oficiais do Remotion, video-use, HeyGen Skills, auto-editor, claude-code-video-toolkit e, só como ideias, SupoClip e OpenMontage. Origem de cada peça: [skill-map.md](references/skill-map.md).

## Princípio central

```
VÍDEO BOM NÃO É O MOTOR. É O GANCHO DOS 3 PRIMEIROS SEGUNDOS,
UM CORTE LIMPO, LEGENDA LEGÍVEL NO CELULAR E SOM NO VOLUME CERTO -
CONFERIDOS EM FRAMES REAIS ANTES DE ENTREGAR.
```

**Tudo gratuito por padrão.** Os clientes são infoprodutores e o usuário já teve créditos queimados sem querer; por isso nenhum passo pago acontece sem pedido explícito e sem custo mostrado antes. Até a cota grátis da HeyGen (3 vídeos/mês) passa por confirmação, porque cada vídeo gasto faz falta no fim do mês.

**Hierarquia de autoridade** (a de cima vence):
1. Regras da casa ([house-rules.md](references/house-rules.md) + RULES-GLOBAL).
2. Identidade do cliente: DESIGN.md, marca, fontes e cores do projeto.
3. O brief do usuário.
4. Conhecimento destilado nas references.

## Etapa 0 - Triagem (sempre, antes de produzir)

Responder estas 4 perguntas, a partir do pedido e dos arquivos. Perguntar ao usuário **uma vez**, e só o que não dá para inferir:

1. **Tipo**: anúncio | reels/shorts | corte de vídeo longo | VSL | motion.
2. **Matéria-prima**: do zero (só tema) | roteiro pronto | vídeo bruto (live/aula/gravação) | só marca + oferta.
3. **Destino**: Feed, Stories, Reels, TikTok, Shorts, YouTube ou página de vendas → define proporção, duração e safe zone ([platform-specs.md](references/platform-specs.md)). Sem destino dito: anúncio e Reels = 9:16; VSL = 16:9 + versão 9:16 do gancho.
4. **Motor**: pela tabela abaixo.

| Situação | Motor | Custo |
|---|---|---|
| Motion, texto animado, dados, template de marca, intro, montagem | **HyperFrames** (render local) | grátis |
| Projeto que **já** usa Remotion (ex.: biômetros, OdontoPricing) | Remotion | grátis até 3 pessoas; avisar licença ([remotion.md](references/remotion.md)) |
| Cortar live/aula, tirar silêncio, legendar vídeo gravado | ffmpeg + Whisper local | grátis |
| Avatar falando, até 1 min | HeyGen Free via MCP | cota 3/mês, com [quota-guard.md](references/quota-guard.md) |
| Qualquer coisa paga (HeyGen API, Higgsfield, Veo, Kling, render na nuvem) | só sob pedido explícito → [paid-on-request.md](references/paid-on-request.md) | mostrar custo e esperar ok |

Rodar `scripts/check-tools.sh` antes de prometer um caminho: ele diz se este ffmpeg queima legenda (o do Homebrew vem sem libass/drawtext), se há Whisper, HyperFrames, MCP da HeyGen e quanto resta da cota. Escolher o motor pelo que existe aqui, não pelo que a receita supõe.

Abrir/atualizar `project.md` na pasta do trabalho com o resultado da triagem (modelo no fim deste arquivo). Ele é a memória do vídeo entre sessões.

## Pipeline

Ler só a reference da etapa atual. O [skill-map.md](references/skill-map.md) diz o conjunto por tipo de vídeo.

| # | Etapa | O que sai | Ler |
|---|---|---|---|
| 1 | **Roteiro e gancho** | roteiro com tempos, gancho dos 3s escrito para som desligado | [hooks-and-ads.md](references/hooks-and-ads.md) · VSL: [vsl-structure.md](references/vsl-structure.md) · corte: [clipping.md](references/clipping.md) |
| 2 | **Direção visual** | paleta, fontes e estilo de legenda tirados da marca do cliente | DESIGN.md do projeto; sem marca, perguntar ou usar presets da `enhanced-design` |
| 3 | **Produção** | composição/edição no motor escolhido | [hyperframes.md](references/hyperframes.md) · [remotion.md](references/remotion.md) · [edit-by-text.md](references/edit-by-text.md) · [heygen.md](references/heygen.md) · [ffmpeg-recipes.md](references/ffmpeg-recipes.md) |
| 4 | **Legenda e áudio** | legenda palavra a palavra, trilha, loudness -14 LUFS / -1 dBTP | [captions.md](references/captions.md) · [ffmpeg-recipes.md](references/ffmpeg-recipes.md) |
| 5 | **QA** | frames extraídos e conferidos, medições de áudio e formato | [qa-checklist.md](references/qa-checklist.md) + `scripts/qa.sh` |
| 6 | **Export e entrega** | um arquivo por formato pedido, `open -R` + caminho absoluto em texto | [platform-specs.md](references/platform-specs.md) |

Regras do pipeline:
- **Gancho antes de tudo.** Se o roteiro não tem um gancho forte nos 3 primeiros segundos, voltar à etapa 1 em vez de caprichar no motion. O feed decide em 1-3s se o vídeo vive.
- **Rascunho barato primeiro.** Renderizar uma prévia curta (5-10s, ou baixa resolução) e conferir frames antes do render final. Erro de safe zone ou de fonte achado na prévia custa segundos; no render final custa minutos.
- **Nunca entregar sem olhar.** "Renderizou sem erro" não é "está certo". Extrair frames (`scripts/qa.sh`) e ver as imagens.
- **Cada corte com fade de áudio de ~30 ms**, para não estalar ([edit-by-text.md](references/edit-by-text.md)).
- Ferramenta ausente (Whisper, HyperFrames, auto-editor): rodar a skill `supply-chain-guard` antes de instalar, preferir versão pinada e registrar no `project.md`.

## Travas de cota e custo

- **HeyGen Free**: rodar `scripts/heygen-quota.sh check` e mostrar "vai usar N de 3 deste mês"; só gerar com o ok do usuário e depois `scripts/heygen-quota.sh use`. Com 3/3, não chamar: oferecer o fallback grátis de [heygen.md](references/heygen.md).
- **Pago** (só sob pedido explícito): ler [paid-on-request.md](references/paid-on-request.md), mostrar custo estimado (US$ e créditos) e esperar confirmação. Vale também para refazer. Chave só em `.env.local`, nunca pelo chat.
- **Mídia do cliente para fora da máquina** (HeyGen, qualquer API): avisar no brief que o rosto/voz do cliente vai para um terceiro e que isso precisa de autorização dele. O padrão (Whisper local) não envia nada.

## Entrega

Ao terminar:
1. `open -R "<arquivo final>"` e o caminho absoluto em texto puro.
2. Resumo curto: formatos gerados, duração, o que foi conferido no QA, cota/custo usado.
3. Atualizar o `project.md` (versão, decisões, o que falta).

## Modelo do project.md

```markdown
# <nome do vídeo>
- Tipo / destino / proporção / duração alvo:
- Matéria-prima:
- Motor:
- Marca (fontes, cores, estilo de legenda):
- Gancho (3s):
## Versões
- v1 AAAA-MM-DD - <arquivo> - <o que mudou>
## Decisões e cotas
- HeyGen: N de 3 em AAAA-MM
## Pendências
```

# Mapa: o que ler em cada tipo de vídeo e de onde veio cada peça

## Conjunto de references por tipo

Ler na ordem, uma por etapa. Sempre: [house-rules.md](house-rules.md) na primeira vez da sessão e [qa-checklist.md](qa-checklist.md) no fim.

| Tipo | Etapa 1 (roteiro) | Etapa 3 (produção) | Etapa 4 | Formato |
|---|---|---|---|---|
| Anúncio do zero | hooks-and-ads | hyperframes (ou heygen para avatar) | captions + ffmpeg-recipes | platform-specs |
| Anúncio a partir de vídeo gravado | hooks-and-ads | edit-by-text + ffmpeg-recipes | captions | platform-specs |
| Reels/Shorts do zero | hooks-and-ads | hyperframes | captions | platform-specs |
| Corte de live/aula | clipping | edit-by-text + ffmpeg-recipes | captions | platform-specs |
| VSL | vsl-structure | edit-by-text (gravada) ou heygen (abertura com avatar) + hyperframes (apoio) | captions + ffmpeg-recipes | platform-specs |
| Motion de marca / intro | - | hyperframes (ou remotion se o projeto já usa) | ffmpeg-recipes (áudio) | platform-specs |
| Pedido pago explícito | - | paid-on-request | - | - |

Cota HeyGen: [quota-guard.md](quota-guard.md) antes de qualquer geração.

## Origem de cada peça

| Reference | Fonte | Licença | O que veio |
|---|---|---|---|
| hyperframes.md | github.com/heygen-com/hyperframes | Apache 2.0 | motor de motion, captions, padrões de vídeo |
| remotion.md | skills oficiais do Remotion + memória "Remotion no Mac" | Remotion License | captions, render, gotchas do Mac |
| edit-by-text.md | github.com/browser-use/video-use | MIT | transcrição → lista de cortes → render → autoconferência; fade 30 ms; ElevenLabs trocada por Whisper local |
| heygen.md / paid-on-request.md | developers.heygen.com, github.com/heygen-com/skills | MIT (skills) | fluxo de avatar, consentimento, MCP, preços |
| ffmpeg-recipes.md | claude-code-video-toolkit (MIT), auto-editor (domínio público), docs do ffmpeg | - | crop/letterbox, CRF, loudnorm, silêncio |
| clipping.md | SupoClip (AGPL) | **só ideias** | critérios de pontuação de trecho viral; nenhum código |
| quota-guard.md | OpenMontage (AGPL) | **só ideias** | portão de aprovação, estimativa antes de gerar; nenhum código |
| platform-specs.md, hooks-and-ads.md, captions.md | Meta creators (10 video best practices), guias de safe zone e LUFS 2026 | - | specs e boas práticas |
| vsl-structure.md | estruturas clássicas de VSL (PAS/AIDA) + skill `copywriting` | - | blocos da VSL |

Nada foi instalado a partir dessas fontes. Nenhum instalador remoto (`npx skills add`, `curl | bash`, `make setup`) é rodado pela skill.

## Skills instaladas que continuam existindo

`video`, `remotion-best-practices`, `higgsfield*`, `whisper`, `youtube-content`, `ad-creative`, `copywriting`. A enhanced-video não depende delas, mas pode chamar `copywriting`/`ad-creative` para variações de texto em escala e `remotion-best-practices` quando o trabalho for fundo em Remotion.

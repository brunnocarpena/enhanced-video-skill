# Enhanced Video

O **maestro de vídeo** para Claude Code. Uma porta de entrada só (`/enhanced-video`, ou só pedir "faz um reels disso") que decide o tipo de vídeo, o motor e a ordem das etapas, lê só a referência de cada etapa e entrega um MP4 conferido em frames reais.

```
triagem (tipo · matéria-prima · destino · motor) → roteiro e gancho dos 3s →
direção visual da marca → produção → legenda e áudio (-14 LUFS) →
QA em frames reais → export por formato → open no arquivo
```

**Premissa: tudo gratuito por padrão.** ffmpeg, Whisper local, HyperFrames e o plano Free da HeyGen. Ferramenta paga só quando o usuário pede, com o custo mostrado antes e confirmação.

## O que ela cobre

| Tipo | Caminho padrão |
|------|----------------|
| Criativo de anúncio (Meta/YouTube, UGC, variações de gancho) | roteiro de gancho → HyperFrames ou edição do gravado → legenda |
| Reels/Shorts/TikTok | gancho → HyperFrames → legenda palavra a palavra |
| Cortes de live/aula longa | Whisper → pontuação de trechos → crop 9:16 → título + legenda |
| VSL / vídeo de vendas | estrutura de VSL → edição pelo texto, avatar HeyGen na abertura (opcional) |
| Motion de marca / intro | HyperFrames (Remotion só em projeto que já usa) |

## Motores

| Motor | Uso | Custo |
|-------|-----|-------|
| [HyperFrames](https://github.com/heygen-com/hyperframes) (HeyGen, Apache 2.0) | motion, texto animado, montagem | grátis, render local |
| Remotion | só projetos que já usam | grátis até 3 pessoas; Company License a partir de 4 |
| ffmpeg + Whisper local | corte, silêncio, legenda, loudness | grátis, nada sai da máquina |
| HeyGen Free via MCP oficial | avatar falando até 1 min | 3 vídeos/mês, com trava de cota |
| HeyGen API, Higgsfield, Veo, Kling, render na nuvem | só sob pedido explícito | pago |

## Estrutura

```
SKILL.md              triagem, tabela de motor, pipeline, travas, entrega
references/           conhecimento por etapa (lido sob demanda)
  skill-map.md        o que ler em cada tipo e de onde veio cada peça
  house-rules.md      regras da casa (acento, hífen, segredos, Mac)
  platform-specs.md   formatos, safe zones, loudness
  hooks-and-ads.md    gancho de 3s, estrutura de criativo, variações
  vsl-structure.md    blocos da VSL e divisão para avatar
  clipping.md         cortes de vídeo longo
  edit-by-text.md     editar pelo texto (Whisper → lista de cortes → render)
  captions.md         legenda palavra a palavra
  hyperframes.md      motor padrão
  remotion.md         projetos existentes + licença
  ffmpeg-recipes.md   crop, cortes com fade, silêncio, loudnorm, ducking
  heygen.md           Free via MCP, consentimento, pt-BR, fallback
  quota-guard.md      contador mensal e portão de aprovação
  paid-on-request.md  ferramentas pagas (só sob pedido)
  qa-checklist.md     checklist antes de entregar
scripts/
  check-tools.sh      preflight: o que este Mac tem (filtros do ffmpeg, Whisper, HeyGen)
  qa.sh               formato, loudness e frames com safe zone
  heygen-quota.sh     check | use | set N
  texto-png.py        legenda/título em PNG transparente (ImageMagick) para overlay
docs/specs/           spec de design
```

## Uso

```
/enhanced-video                                   # triagem pelo contexto
/enhanced-video corte aula.mp4 --destino=reels    # 3 Reels de uma aula
/enhanced-video anuncio "lançamento CRT22"        # criativo com variações de gancho
/enhanced-video vsl roteiro.md --destino=pv
```

## Instalação

```bash
git clone https://github.com/brunnocarpena/enhanced-video-skill ~/.claude/skills/enhanced-video
```

Dependências: `ffmpeg` (obrigatório; o do Homebrew vem sem libass/drawtext, e a skill contorna com HyperFrames ou PNG + overlay) e `imagemagick` (gera os PNG de texto). Rodar `scripts/check-tools.sh` para ver o que falta. Sob demanda, instaladas só depois de passar pela skill `supply-chain-guard`: Whisper (whisper.cpp ou `uvx openai-whisper`), HyperFrames (`npm exec --package=hyperframes@<versão pinada>`, versão com 7+ dias), MCP da HeyGen (`claude mcp add --transport http -s user heygen https://mcp.heygen.com/mcp/v1/` + login OAuth).

## Fontes destiladas

Conteúdo destilado, nada instalado e nenhum código AGPL copiado: HyperFrames (Apache 2.0), skills oficiais do Remotion, [video-use](https://github.com/browser-use/video-use) (MIT), [HeyGen Skills](https://github.com/heygen-com/skills) (MIT) e docs do MCP, auto-editor (domínio público), claude-code-video-toolkit (MIT), e só como ideias SupoClip e OpenMontage (AGPL). Detalhe em [references/skill-map.md](references/skill-map.md).

## Atualizar

Preços e limites de HeyGen, Higgsfield, Veo e afins mudam. Itens marcados **(verificar)** nas references ainda não foram confirmados em doc oficial; confirmar antes de prometer ao cliente e atualizar a reference com a data.

## Licença

MIT.

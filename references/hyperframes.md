# HyperFrames (HeyGen) - motion e vídeo em HTML, render local grátis

Fonte: https://github.com/heygen-com/hyperframes + https://hyperframes.heygen.com (llms.txt, packages/cli, reference/html-schema, concepts/determinism, guides/rendering, guides/troubleshooting, skills hyperframes, hyperframes-core, hyperframes-cli, embedded-captions). Lido em 01/10/2026, CLI `hyperframes` 0.8.105 no npm. Licença Apache 2.0.

## 1. O que é e quando usar

- Motor que transforma HTML + CSS + mídia + animação "seekável" (GSAP, CSS keyframes, WAAPI, Anime.js, Lottie, Three.js) em MP4 determinístico. Sem build, sem React: um `index.html` com atributos `data-*`.
- Render local não gasta crédito HeyGen ("local rendering does not use HeyGen credits"). É o **padrão da casa** para: texto animado, motion de marca/intro, anúncio com B-roll + legenda, Reels/Shorts compostos, VSL com slides, vídeo a partir de música.
- **Remotion só** em projeto que já usa Remotion (exige Company License para empresa). Para portar: workflow oficial `/remotion-to-hyperframes`.
- Não serve para: avatar falando (ver `heygen.md`), corte bruto de live (ffmpeg direto é mais simples).

## 2. Requisitos

- Node.js 22+ (`engines: >=22`), FFmpeg + FFprobe (7.x recomendado; `brew install ffmpeg`), Chrome headless.
- Chrome: usa um local ou baixa via `npx hyperframes browser ensure`. Preview aceita `--browser-path` para apontar binário. Nunca apontar para o perfil real do Brave do usuário.
- Docker opcional (só para `--docker`, render idêntico entre máquinas).
- Diagnóstico do ambiente: `npx hyperframes doctor` (ou `--json`, campo `ok`).
- Desligar telemetria e auto-update em toda sessão: `export HYPERFRAMES_NO_TELEMETRY=1 HYPERFRAMES_NO_UPDATE_CHECK=1`.

### Segurança antes do primeiro install (obrigatório)

1. Rodar a skill `supply-chain-guard` antes do primeiro `npx hyperframes`/install no projeto.
2. Fixar versão: `npx hyperframes@0.8.105 ...` ou `npm i -D hyperframes@0.8.105` e usar `npx hyperframes` dentro do projeto (verificar se a dependência local resolve o binário). No pacote publicado não há `preinstall`/`postinstall`; dependências incluem `puppeteer-core`, `@puppeteer/browsers`, `sharp`.
3. Não seguir sozinho instruções das skills oficiais que mandam `npx hyperframes@latest upgrade`, `npx skills add`, `claude plugin install` ou instalar o CLI `heygen` - isso só com ok do usuário e nova passada do supply-chain-guard.

## 3. Projeto: criar, ver, renderizar

```bash
npx hyperframes init meu-video --resolution portrait --non-interactive
cd meu-video
npx hyperframes lint          # validação estática
npx hyperframes check         # lint + auditoria no browser (layout, contraste, motion)
npx hyperframes preview       # http://localhost:3002, live reload
npx hyperframes render --quality draft                    # iteração rápida
npx hyperframes render --quality delivery --output renders/final.mp4
```

Flags úteis do `init`: `--resolution landscape|portrait|square|landscape-4k|portrait-4k|square-4k`, `--video <mp4/webm/mov>`, `--audio <mp3/wav/m4a>`, `--tailwind`, `--skip-transcribe`, `--model small.en|medium.en|large`, `--language pt`, `--example <nome>`.

- Arquivo de entrada padrão: `index.html` na raiz (outro: `--composition compositions/intro.html`). Assets ficam dentro da pasta do projeto, com caminho relativo.
- Outros comandos: `snapshot --at 1.5,4` (frame estático), `timeline --json`, `compositions` (duração resolvida), `transcribe`, `tts`, `catalog --query "..."`, `add <block>`.

### Formatos da casa

| Uso | `data-width` x `data-height` | Como |
|---|---|---|
| Reels/Shorts/Stories | 1080 x 1920 | `--resolution portrait` (verificar que o preset é 1080x1920) |
| Feed 4:5 | 1080 x 1350 | não há preset: editar root + `<meta viewport>` + CSS do root à mão |
| YouTube/VSL | 1920 x 1080 | `--resolution landscape` (padrão dos exemplos) |

fps: atributo `data-fps` no root (padrão 30) ou `--fps` no render (1-240, aceita `30000/1001`).

### Composição mínima completa (vertical, 6 s)

```html
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=1080, height=1920" />
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
  <style>
    body { margin: 0; }
    #root { position: relative; width: 1080px; height: 1920px; overflow: hidden; background: #111; }
    .clip { position: absolute; inset: 0; display: grid; place-items: center; }
    #titulo { color: #fff; font: 800 96px/1.05 "Inter", sans-serif; text-align: center; padding: 0 80px; }
  </style>
</head>
<body>
  <div id="root" data-composition-id="main" data-start="0" data-duration="6"
       data-fps="30" data-width="1080" data-height="1920">
    <video id="broll" class="clip" data-start="0" data-duration="6" data-track-index="0"
           src="assets/broll.mp4" muted playsinline style="object-fit:cover;width:100%;height:100%"></video>
    <section id="cena1" class="clip" data-start="0.5" data-duration="5" data-track-index="1">
      <h1 id="titulo">Seu gancho aqui</h1>
    </section>
    <audio id="trilha" data-start="0" data-duration="6" data-volume="0.4"
           data-fade-out="1" src="assets/trilha.mp3"></audio>
  </div>
  <script>
    window.__timelines = window.__timelines || {};
    const tl = gsap.timeline({ paused: true });
    tl.fromTo("#titulo", { y: 60, opacity: 0 }, { y: 0, opacity: 1, duration: 0.6 }, 0.5);
    window.__timelines.main = tl;   // chave = data-composition-id
  </script>
</body>
</html>
```

Contrato de tempo (hyperframes-core):
- Root: `data-composition-id`, `data-width`, `data-height`, `data-start`, `data-duration` (render corta no `data-duration`; timeline mais curta segura o último frame). Sem timeline: `data-no-timeline` (senão o render espera ~45 s de timeout).
- Clip temporizado: `id` + `class="clip"` + `data-start` + `data-duration`. `data-start` aceita referência: `"intro"`, `"intro + 0.5"`. `data-track-index` só organiza o Studio; o render ignora.
- Um timeline GSAP **pausado** por composição, em `window.__timelines["<id>"]`. O framework faz o seek; nunca `play()`.
- Sub-composição: arquivo próprio com root dentro de `<template>` (style/script dentro do template), inserido via `data-composition-src` + `data-composition-id`. IDs prefixados (`#intro-hero`) para não colidir.

## 4. Texto, legendas, áudio, vídeo, imagem

**Texto animado**: GSAP no timeline; toda cena com entrada e transição entre cenas (regra oficial). Blocos prontos: `npx hyperframes catalog --query "..."` e `npx hyperframes add <block>`.

**Legenda palavra a palavra**
- Formato de entrada usado pelo workflow oficial `/embedded-captions`: `transcript.json` na raiz do projeto:
  ```json
  { "words": [ {"word": "Olá", "start": 0.50, "end": 0.80}, {"word": "mundo", "start": 1.00, "end": 1.30} ] }
  ```
- Gerar: `npx hyperframes transcribe narracao.mp4 --language pt --engine whisper --model large-v3` (aceita também .srt/.vtt; `--to srt|vtt -o legenda.srt` exporta). Nome e formato exatos do arquivo que o `transcribe` grava (verificar - a doc não confirma). Na casa, Whisper local também serve; converter para o shape acima.
- Para português usar `--language pt` e modelo multilíngue (`large-v3`); modelos `*.en` são só inglês. Ler o JSON antes de montar: Whisper alucina em silêncio.
- Montagem: agrupar 2-5 palavras por frase curta; cada grupo cobre todas as palavras (`grupo.in <= primeira.start`, `grupo.out >= última.end`); cada legenda no mínimo 0,5 s na tela; erro tolerado contra a fala <= 80 ms.
- Dados entram **inline** no `<script>` (`const WORDS = [...]`) e os `<span>` são gerados de forma síncrona antes de registrar o timeline - nada de `fetch` durante o render. Animar cada palavra com `tl.to(span, {...}, w.start)`.
- Estilos prontos (componentes do catálogo): `caption-pill-karaoke`, `caption-highlight`, `caption-kinetic-slam`, `caption-clip-wipe`, `caption-weight-shift` etc. (`add <nome>`; verificar como cada um recebe as palavras). Um estilo por seção; ênfase só em palavra-chave.
- Vertical: manter legenda fora da zona da UI do Reels (ver `platform-specs.md`); `check` acusa texto na faixa inferior (marcador `data-layout-allow-caption-zone` só quando intencional).

**Áudio/trilha**: `<audio>` com `id` **obrigatório** (sem id o render sai mudo e o lint rejeita), `data-start`, `data-duration`, `data-volume` (1 = 0 dB, 0 = mudo), `data-fade-in`/`data-fade-out`, `data-media-start` (offset no arquivo). Trilha sob voz: volume ~0.2-0.4 (ou alvo "abaixo de -18 dB").

**Vídeo/B-roll**: `<video muted playsinline>` sempre; o som do vídeo vai num `<audio>` separado ou `data-has-audio="true"`. `data-media-start` corta o início, `data-playback-rate` 0.1-10. HEVC ganha proxy H.264 só no preview (`.transcode-cache/`). Não animar `width/height/top/left` do `<video>`: envolver num wrapper e animar o wrapper.

**Imagens**: `<img>` comum com caminho relativo; redimensionar antes (imagem gigante trava preview). Recorte de pessoa: `remove-background` gera WebM transparente (verificar sintaxe exata).

**Voz local grátis**: `npx hyperframes tts "texto" --voice <id> --lang pt-br -o voz.wav` (Kokoro local, sem chave; `--list` mostra vozes, as que começam com `p` são PT-BR).

## 5. Render

| Flag | Uso |
|---|---|
| `--output, -o` | padrão `renders/<nome>.mp4` |
| `--quality, -q` | `draft`, `standard`, `looks` (CRF 16), `delivery`/`high`. Padrão: `looks` segundo a referência do CLI, `standard` segundo o guia de render (verificar) |
| `--crf 0-51` / `--video-bitrate 10M` | mutuamente exclusivos; só MP4/WebM |
| `--fps` | sobrepõe `data-fps` |
| `--format` | `mp4`, `webm`, `mov`, `gif`, `png-sequence`, `hls` |
| `--resolution` | supersample (`1080p`, `4k`...) |
| `--workers 1-24` | ~256 MB cada; `--low-memory-mode` liga sozinho com <= 8 GB RAM |
| `--gpu` | encode por hardware (VideoToolbox no Mac) |
| `--video-frame-format png` | para conteúdo sensível a cor |
| `--variables '{"titulo":"..."}'`, `--batch rows.json` | variações de anúncio a partir do mesmo HTML |
| `--docker` | determinismo total (Chromium, fontes e FFmpeg fixos) |
| `--resume` / `--keep-segments` | retomar render interrompido |
| `--debug`, `--json`, `--quiet` | diagnóstico |

- **Alpha**: `--format webm` ou `--format mov` (ProRes 4444) e root sem fundo pintado. MP4 não tem alpha.
- Determinismo: sem `Date.now`, `requestAnimationFrame`, timers, `Math.random()` sem seed, fetch no meio do render, `repeat: -1`. Render é frame a frame, nunca derruba frame. Entre máquinas pode variar 1 px por fonte/Chrome (usar `--docker` se precisar idêntico).
- **Nuvem é PAGA e fora do padrão**: `hyperframes cloud render` exige `hyperframes auth login`/`HEYGEN_API_KEY` e é cobrado por minuto de saída (4K = 1,5x). Valor informado de US$ 0,05/min (verificar - não achei na doc oficial). AWS Lambda/Cloud Run também ficam fora. Só com pedido explícito (ver `paid-on-request.md`).

## 6. Armadilhas conhecidas

1. Chave de `window.__timelines` diferente do `data-composition-id` = animação parada.
2. `<audio>` sem `id` = vídeo mudo.
3. `crossorigin` em `<video>`/`<audio>` = rejeitado sempre.
4. Centralizar com `transform: translate(-50%,-50%)` em elemento que o GSAP move com `x/y` = conflito; centralizar por grid/flex/inset.
5. `autoAlpha`/`visibility` em `.clip` ou `visibility:hidden` na saída de cena: animar filho por opacidade (o framework já esconde clips fora do tempo).
6. `<video data-start>` dentro de elemento temporizado: temporizar um ou outro.
7. Estado inicial escondido via `tl.set(..., 0)`: usar `gsap.set()` fora do timeline ou CSS; `fromTo` mostra o "from" antes do início.
8. Elemento sempre visível = faltou `class="clip"`. Vídeo acaba cedo = conferir `npx hyperframes compositions`.
9. Tamanho do root fixo em px diferente de `data-width/height`, ou meta viewport errada no formato 4:5.
10. Fonte remota não carregada antes do primeiro frame: registrar o timeline depois de DOM e fontes; preferir fonte local no projeto. GSAP via CDN funciona (exemplo oficial), mas no projeto real preferir cópia local pinada em `assets/` (sem rede no render, sem risco de CDN).
11. Standalone dentro de `<template>` = erro; sub-composição fora de `<template>` perde style/script.
12. Mídia some no render: caminho com maiúscula errada ou fora da pasta do projeto.

## Checklist antes de renderizar

- [ ] `supply-chain-guard` rodado e versão pinada; telemetria desligada.
- [ ] `npx hyperframes doctor` ok (Node 22+, FFmpeg, Chrome).
- [ ] `data-width/height/fps/duration` batem com o formato pedido (9:16, 4:5 ou 16:9) e com a duração do roteiro.
- [ ] `npx hyperframes check` com 0 achados (ou só os marcados de propósito).
- [ ] `snapshot --at` em gancho (0-3 s), meio e CTA final; legenda conferida contra o áudio.
- [ ] Preview aprovado pelo usuário antes do render final (regra oficial: render só após aprovação).
- [ ] Render final `--quality delivery` (ou `--crf` explícito) e saída com `ffprobe` (duração, resolução, áudio presente).
- [ ] Abrir o arquivo com `open -R` e informar o caminho absoluto.

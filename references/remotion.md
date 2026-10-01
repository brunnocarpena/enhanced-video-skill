# Remotion (só em projeto que já usa)

O motor padrão é o HyperFrames. O Remotion entra só quando o projeto **já** tem Remotion (ex.: Gerador de Biômetros, OdontoPricing). Para trabalho fundo de Remotion, chamar também a skill `remotion-best-practices`.

## Licença (avisar sempre)

A Remotion License é grátis para pessoa física e para empresa com **até 3 pessoas**. Com 4 ou mais, exige a Company License paga. Ao usar Remotion num projeto de cliente, avisar uma vez: "Este projeto usa Remotion; se a empresa do cliente (ou a nossa) tiver 4+ pessoas, precisa da Company License." Não começar projeto novo em Remotion por causa disso.

## Gotchas do Mac (vividos)

- **Rodar do `$HOME`**: com o projeto em `~/Documents`, o macOS dá `EPERM: operation not permitted, uv_cwd`. Rodar o CLI a partir de `$HOME` com caminhos absolutos:
  ```bash
  cd "$HOME" && npx remotion render "/abs/projeto/src/index.ts" <CompositionId> "/abs/saida/video.mp4" \
    --public-dir "/abs/projeto/public"
  ```
  Sem `--public-dir`, `staticFile()` não acha os assets quando o cwd não é o projeto.
- **Fonte com acento**: Cormorant Garamond desloca os acentos do PT-BR no render. Usar Lora (serifada) ou uma sans da marca.
- **QA no meio da cena**: frame no início de cena pega a animação de entrada pela metade e engana. Extrair frames do meio de cada cena (`npx remotion still ... --frame=N`).
- `.nvmrc` = 22.

## Captions

`@remotion/captions`: converter a transcrição do Whisper (tempo por palavra) para o formato `Caption[]` e usar `createTikTokStyleCaptions()` para montar as páginas de 3-5 palavras com a palavra ativa. Estilo e posição seguem [captions.md](captions.md).

## Render

- Prévia barata: `--frames=0-150` ou `--scale=0.5` antes do render completo.
- Saída padrão: `--codec=h264 --crf=18`, depois loudness via [ffmpeg-recipes.md](ffmpeg-recipes.md) (o Remotion não normaliza áudio).
- Render na nuvem (Lambda) é pago: só sob pedido ([paid-on-request.md](paid-on-request.md)).

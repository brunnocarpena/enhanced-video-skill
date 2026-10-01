# Legenda

85% do feed assiste sem som. Legenda não é acessório: é o canal principal. Sempre legendar Reels, Shorts, anúncio e corte.

## Padrão (estilo "palavra a palavra")

| Item | Padrão |
|---|---|
| Palavras por bloco | 3-5 (nunca mais de 2 linhas) |
| Destaque | a palavra falada no momento muda de cor (cor de destaque da marca) ou de escala (+10%) |
| Fonte | sans bold/black da marca; sem marca: Montserrat ExtraBold, Poppins Bold ou Inter Black |
| Tamanho | 64-80 px em 1080×1920 (≥ 5% da altura) |
| Cor | branco com contorno preto 3-4 px (ou sombra forte); nunca texto fino sem contorno |
| Posição | terço central da área útil: y ~ 900-1250 em 9:16 (acima da UI da base, abaixo do rosto) |
| Caixa | maiúsculas OU frase normal, mas a mesma no vídeo todo |
| Pontuação | tirar vírgula e ponto final; manter "?" e "!" |
| Timing | bloco aparece no `start` da 1ª palavra e some no `end` da última; nunca antes da fala |

Ênfase extra (opcional, sem exagero): 1-2 palavras-chave por frase em cor de destaque; emoji só se o cliente usa.

Acentos e hífen: conferir antes do render ([house-rules.md](house-rules.md)). Fonte que desloca acento é trocada.

## Montar os blocos a partir da transcrição

Entrada: `transcricao.json` (tempo por palavra, ver [edit-by-text.md](edit-by-text.md)), já ajustada para a timeline depois dos cortes.

Regras de quebra:
- fechar o bloco ao atingir 5 palavras, ou numa pausa > 0,4s, ou num ponto final;
- não deixar artigo/preposição sozinho no fim do bloco ("de", "a", "o", "para") - puxar para o próximo;
- bloco com uma palavra só, só se for ênfase intencional.

## Como queimar no vídeo

| Motor | Como |
|---|---|
| HyperFrames | componente de captions com destaque por palavra ([hyperframes.md](hyperframes.md)) - melhor visual |
| Remotion | `@remotion/captions` ([remotion.md](remotion.md)) |
| ffmpeg puro | gerar `.ass` com estilo e `\k` por palavra (karaokê) e queimar com `-vf "ass=legenda.ass"` ([ffmpeg-recipes.md](ffmpeg-recipes.md)) |

**Antes, conferir se o ffmpeg queima legenda**: `scripts/check-tools.sh` (ou `ffmpeg -filters | grep -wE "ass|drawtext"`). O `ffmpeg` do Homebrew vem sem libass e sem freetype: `ass`, `subtitles` e `drawtext` não existem e o comando falha com "No such filter". Nesse caso, em ordem:

1. **HyperFrames** com o vídeo como `<video class="clip">` e a legenda em HTML por cima (renderiza no Chromium, não depende de libass). É o caminho padrão.
2. **PNG transparente + `overlay`**: um PNG por bloco com `scripts/texto-png.py` (só ImageMagick, sem navegador; já quebra linha na largura da área útil, faz contorno, caixa de fundo e palavra em destaque) e sobrepor com `overlay=x=(W-w)/2:y=Y:enable='between(t,INI,FIM)'`. Serve para título do gancho, CTA e também para legenda inteira quando o HyperFrames não está à mão. Só se o ImageMagick faltar, cair para HTML num Chromium headless (perfil temporário, matar só pelo PID próprio): no eval de 01/10 o `--screenshot` do Brave travou e o CDP funcionou.
3. **`ffmpeg-full`** do Homebrew (grátis, keg-only, tem libass): só depois da `supply-chain-guard` e do ok do usuário; chamar pelo caminho completo `$(brew --prefix)/opt/ffmpeg-full/bin/ffmpeg`.

Nunca entregar o vídeo sem legenda e dizer que "faltou o filtro": escolher um dos caminhos acima.

O `.ass` permite estilo completo (fonte, contorno, posição, cor de destaque via karaokê) e é o caminho mais leve para cortes de live. Para fonte que não está instalada no sistema, passar `fontsdir` no filtro (`ass=legenda.ass:fontsdir=./fontes`).

Também exportar o `.srt` ao lado do MP4: plataformas aceitam legenda fechada e isso ajuda acessibilidade e busca.

## Checklist

- [ ] Nenhum bloco com mais de 5 palavras ou 2 linhas
- [ ] Dentro da área útil, sem colidir com rosto nem UI. A largura do bloco nunca passa de 865 px no 9:16 (o `texto-png.py` já respeita); com pessoa real no quadro, a legenda fica abaixo do queixo, não em cima da boca: conferir no frame e descer o bloco (~80 px costuma bastar) mantendo o topo do texto acima de y=1250
- [ ] Sincronizada (conferir 3 frames com a palavra esperada)
- [ ] Acentos corretos, nomes próprios corretos

# Receitas de ffmpeg

Fontes: claude-code-video-toolkit (MIT), auto-editor (domínio público) e documentação do ffmpeg. O ffmpeg já está instalado. Sempre caminhos entre aspas (as pastas têm espaço e acento).

## Export padrão

```bash
ffmpeg -i entrada.mp4 -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -r 30 \
  -c:a aac -b:a 192k -ar 48000 -ac 2 -movflags +faststart saida.mp4
```

CRF 18 = quase sem perda visível; 20-23 para arquivo menor. `yuv420p` e `+faststart` evitam vídeo preto em alguns players e permitem tocar antes de baixar tudo.

## Proporções

```bash
# 16:9 → 9:16, crop no centro
-vf "crop=ih*9/16:ih,scale=1080:1920,setsar=1"

# 16:9 → 9:16, crop com o rosto em X% da largura (ex.: 0.62)
-vf "crop=ih*9/16:ih:(iw*0.62)-(ih*9/16)/2:0,scale=1080:1920,setsar=1"

# 16:9 → 9:16 com faixa: vídeo inteiro em cima, fundo da marca
-vf "scale=1080:-2,pad=1080:1920:0:300:color=#1a1a1a,setsar=1"

# 16:9 → 4:5 (feed), crop no centro
-vf "crop=ih*4/5:ih,scale=1080:1350,setsar=1"

# letterbox (encaixar sem cortar) em 1080×1920
-vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1"
```

Na receita do rosto, se o crop sair da imagem, limitar o x: `max(0,min(iw-ih*9/16, <x>))`.

## Cortar e emendar trechos (com fade de 30 ms)

Para cada trecho `i` com início `S` e fim `E` (segundos), duração `D=E-S`:

```
[0:v]trim=S:E,setpts=PTS-STARTPTS[v0];
[0:a]atrim=S:E,asetpts=PTS-STARTPTS,afade=t=in:d=0.03,afade=t=out:st=D-0.03:d=0.03[a0];
```

e no fim `[v0][a0][v1][a1]...concat=n=N:v=1:a=1[v][a]`, com `-map "[v]" -map "[a]"`. Gerar o filtro por script a partir do `cortes.json` e passar com `-filter_complex_script filtro.txt` quando ficar longo.

Corte único rápido (sem reencodar, bordas só em keyframe, impreciso): `ffmpeg -ss 00:01:10 -to 00:01:45 -i in.mp4 -c copy out.mp4`. Para corte preciso, reencodar.

## Silêncio

Detectar (grátis, sem instalar nada):

```bash
ffmpeg -i entrada.mp4 -af silencedetect=noise=-35dB:d=0.6 -f null - 2>&1 | grep silence_
```

Gera `silence_start`/`silence_end`; transformar em lista de trechos que ficam (com ~0,2s de respiro) e usar a receita acima.

auto-editor (corte automático de silêncio, domínio público) não está instalado. Se o usuário quiser, passar pelo `supply-chain-guard` e rodar com `uvx auto-editor entrada.mp4 --margin 0.2sec --edit audio:threshold=0.04`. Parâmetros equivalentes aos do `silencedetect`.

## Loudness (-14 LUFS, -1 dBTP) em duas passadas

```bash
# 1ª passada: medir
ffmpeg -i in.mp4 -af loudnorm=I=-14:TP=-1:LRA=11:print_format=json -f null - 2>&1 | tail -12

# 2ª passada: aplicar com os valores medidos
ffmpeg -i in.mp4 -af "loudnorm=I=-14:TP=-1:LRA=11:measured_I=<input_i>:measured_TP=<input_tp>:measured_LRA=<input_lra>:measured_thresh=<input_thresh>:offset=<target_offset>:linear=true" \
  -c:v copy -c:a aac -b:a 192k -ar 48000 out.mp4
```

Uma passada só funciona, mas comprime de forma dinâmica e pode "bombear". Duas passadas com `linear=true` mantêm a dinâmica.

## Trilha por baixo da voz (ducking)

```bash
ffmpeg -i voz.mp4 -i trilha.mp3 -filter_complex \
 "[1:a]volume=0.25[m];[m][0:a]sidechaincompress=threshold=0.03:ratio=8:attack=20:release=400[duck];[0:a][duck]amix=inputs=2:duration=first:normalize=0[a]" \
 -map 0:v -map "[a]" -c:v copy -c:a aac out.mp4
```

Trilha só de banco livre (YouTube Audio Library, Pixabay Music) ou fornecida pelo cliente. Normalizar loudness depois da mixagem.

## fps

```bash
# HeyGen (25 fps) → 30 fps antes de montar com material 30 fps
ffmpeg -i heygen.mp4 -vf fps=30 -c:v libx264 -crf 18 -pix_fmt yuv420p -c:a copy heygen-30.mp4
```

## Legenda

```bash
# queimar .ass (estilo + karaokê por palavra)
-vf "ass=legenda.ass:fontsdir=./fontes"

# texto fixo (ex.: título do gancho nos 3 primeiros segundos)
-vf "drawtext=fontfile=/abs/Montserrat-ExtraBold.ttf:text='3 sinais de energia travada':fontsize=72:fontcolor=white:borderw=4:bordercolor=black:x=(w-text_w)/2:y=320:enable='lt(t,3)'"
```

No `drawtext`, apóstrofo e dois-pontos precisam de escape; para texto com pontuação, usar `textfile=titulo.txt`.

## Concatenar arquivos já no mesmo formato

```bash
printf "file '%s'\n" "/abs/a.mp4" "/abs/b.mp4" > lista.txt
ffmpeg -f concat -safe 0 -i lista.txt -c copy junto.mp4
```

Só funciona com mesmo codec, resolução, fps e áudio. Se não bater, reencodar cada um no export padrão antes.

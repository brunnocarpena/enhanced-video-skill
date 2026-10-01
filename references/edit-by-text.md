# Editar pelo texto (vídeo gravado)

Método destilado do video-use (browser-use, MIT): o vídeo vira texto com tempo por palavra, a edição é feita no texto, e o ffmpeg executa a lista de cortes. A transcrição paga (ElevenLabs) foi trocada por **Whisper local, grátis**: o vídeo do cliente não sai da máquina.

## 1. Transcrição

Whisper não vem instalado. Rodar a skill `supply-chain-guard` antes de instalar e escolher uma opção:

| Opção | Instalar | Rodar |
|---|---|---|
| whisper.cpp (rápido no Apple Silicon) | `brew install whisper-cpp` + baixar um modelo ggml (ex.: `ggml-large-v3-turbo.bin`) | `whisper-cli -m <modelo> -l pt -ojf -ml 1 -sow -f audio.wav` |
| openai-whisper via uvx (sem instalar global) | nada além do `uv` | `uvx --from openai-whisper whisper audio.mp3 --model turbo --language pt --word_timestamps True --output_format json` |

Antes de transcrever, extrair o áudio em 16 kHz mono (o whisper.cpp exige WAV 16 kHz):

```bash
ffmpeg -i entrada.mp4 -vn -ac 1 -ar 16000 -c:a pcm_s16le audio.wav
```

Saída: JSON com cada palavra e seu `start`/`end`. Salvar como `transcricao.json`. Registrar no `project.md` qual opção e modelo foram usados.

Conferir nomes próprios e termos do nicho (radiestesia, pêndulo, nomes de alunos) e corrigir na transcrição antes de usar para legenda.

## 2. Lista de cortes

Ler a transcrição e montar `cortes.json`: os trechos que **ficam**, em ordem.

```json
[
  {"inicio": 3.42, "fim": 18.90, "motivo": "abertura sem o 'oi gente'"},
  {"inicio": 21.10, "fim": 47.35, "motivo": "pula a frase repetida 18.9-21.1"}
]
```

O que cortar:
- silêncio > 0,6s (deixar ~0,15-0,25s de respiro nas bordas, não colar palavra com palavra);
- frases repetidas (ficar com a última tentativa, que costuma ser a melhor);
- muletas no início de frase ("é...", "então", "tipo"), quando cortar não deixa a fala robótica;
- erros que a pessoa corrige em seguida.

Bordas sempre em limite de palavra (usar o `end` de uma palavra e o `start` da próxima). Mostrar ao usuário a lista resumida (duração antes → depois, o que saiu) antes do render final se o vídeo for longo ou de cliente importante.

Corte automático só de silêncio, sem olhar o texto: ver auto-editor em [ffmpeg-recipes.md](ffmpeg-recipes.md).

## 3. Render

Cortar cada trecho e concatenar, com **fade de áudio de ~30 ms** no início e no fim de cada trecho. Sem isso, cada corte dá um "clique" audível.

Receita em [ffmpeg-recipes.md](ffmpeg-recipes.md), seção "Cortar e emendar trechos". Para muitos trechos, gerar o filtro por script (um `trim`/`atrim` + `afade` por trecho e um `concat` no fim) em vez de escrever à mão.

Se a lista de cortes muda depois, a transcrição também muda: recalcular os tempos das palavras para a timeline nova (subtrair o que foi cortado antes de cada palavra) antes de gerar a legenda.

## 4. Autoconferência

Depois do render, conferir **cada ponto de corte**:
- extrair um frame 0,1s antes e 0,1s depois de cada emenda e olhar (pulo de enquadramento muito brusco → considerar punch-in de 10-15% num dos lados para virar "jump cut" intencional);
- ouvir não dá, então medir: rodar `scripts/qa.sh` (loudness) e procurar picos nos pontos de corte com `astats` se houver suspeita de clique;
- a duração final bate com a soma dos trechos?

Problema achado → corrigir a lista de cortes e renderizar de novo. Só então seguir para legenda.

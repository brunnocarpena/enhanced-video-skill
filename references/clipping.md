# Cortes de live/aula longa → Reels/Shorts

Ideias de pontuação inspiradas no SupoClip (AGPL): **só os critérios, nenhum código**. Tudo roda local e grátis: Whisper + ffmpeg.

## Fluxo

1. **Transcrever com tempo por palavra** (Whisper local, ver [edit-by-text.md](edit-by-text.md) seção "Transcrição"). Salvar `transcricao.json` ao lado do vídeo.
2. **Achar candidatos**: ler a transcrição e marcar trechos de 20-60s que fazem sentido **sozinhos** (começo e fim de ideia, sem "como eu falei antes").
3. **Pontuar** cada candidato de 0 a 10 em 4 critérios:

| Critério | Pergunta | Peso |
|---|---|---|
| Gancho | a primeira frase prende sem contexto? | 3 |
| Valor | ensina, revela ou resolve algo concreto? | 3 |
| Emoção / energia | tem história, humor, indignação, virada, voz mais alta? | 2 |
| Compartilhável | alguém mandaria para um amigo? frase citável? | 2 |

   Nota = soma ponderada / 10. Apresentar ao usuário uma tabela com os **5-8 melhores** (início-fim, nota, primeira frase, título proposto) e deixar ele escolher, a menos que o pedido já diga "escolhe você os 3 melhores".
4. **Ajustar as bordas**: começar exatamente na primeira palavra do gancho (cortar "então", "é...", respiração), terminar depois da última palavra da ideia + ~0,3s. Bordas em limite de palavra, nunca no meio.
5. **Enquadrar em 9:16** (abaixo).
6. **Título de gancho queimado** nos primeiros 2-3s, no topo da área útil (y ≥ 270), 5-8 palavras.
7. **Legenda palavra a palavra** ([captions.md](captions.md)).
8. **Loudness** -14 LUFS e export ([ffmpeg-recipes.md](ffmpeg-recipes.md)).
9. **QA** de cada corte ([qa-checklist.md](qa-checklist.md)).

## Enquadrar 16:9 → 9:16

| Situação | Como |
|---|---|
| Uma pessoa, rosto parado no centro | crop central `crop=ih*9/16:ih` e escala para 1080×1920 |
| Rosto fora do centro, parado | medir a posição do rosto num frame e fixar o x do crop nela |
| Pessoa se mexe muito | crop por trechos (x diferente por segmento) ou layout com faixa |
| Tela compartilhada / slide importante | **layout com faixa**: vídeo 16:9 inteiro em cima (1080 de largura), título e legenda embaixo, fundo da cor da marca |
| Duas pessoas (entrevista) | layout empilhado: cada rosto numa metade 1080×960 |

Para achar o x do rosto sem instalar nada: extrair 3-5 frames do trecho, olhar as imagens e estimar a posição horizontal do rosto (em % da largura). Arredondar para par. Detecção automática de rosto (ex.: mediapipe) só se o usuário quiser, e passando pelo `supply-chain-guard`.

Receitas de ffmpeg do crop e da faixa: [ffmpeg-recipes.md](ffmpeg-recipes.md).

## Nomes de arquivo

`<origem>-corte-01-<slug-do-titulo>.mp4`, numerados na ordem da nota. Uma tabela final no `project.md` com início-fim na gravação original, nota e título de cada corte.

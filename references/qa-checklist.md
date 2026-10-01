# QA antes de entregar

"Renderizou sem erro" não é "está certo". Rodar o script e **olhar as imagens**.

```bash
~/.claude/skills/enhanced-video/scripts/qa.sh "/abs/video.mp4" [--destino=reels] [--frames=6]
```

Ele imprime resolução, proporção, fps, codec, duração, loudness integrado/pico real/LRA e extrai N frames espaçados (mais o frame 0) para `<video>-qa/`, com a safe zone desenhada por cima nos destinos 9:16. Depois, abrir os PNG com o Read e conferir.

## Checklist

**Formato**
- [ ] Resolução e proporção do destino ([platform-specs.md](platform-specs.md))
- [ ] 30 fps (ou o fps combinado), H.264, yuv420p
- [ ] Duração dentro do alvo

**Gancho**
- [ ] Frame 0 não é preto, logo parado nem fade
- [ ] Texto do gancho legível no frame 0-1s

**Imagem e texto**
- [ ] Texto, legenda e rosto dentro da área útil (retângulo desenhado pelo script)
- [ ] Acentos corretos e sem travessão em todo texto visível
- [ ] Sem palavra órfã, sem texto cortado na borda
- [ ] Legenda sincronizada (palavra destacada = palavra falada nos frames conferidos)
- [ ] Cores e fontes da marca

**Áudio**
- [ ] Loudness entre -15 e -13 LUFS, pico real ≤ -1 dBTP
- [ ] Sem clique nos cortes (fades de 30 ms aplicados)
- [ ] Trilha abaixo da voz

**Cortes (vídeo editado)**
- [ ] Frames antes/depois de cada emenda conferidos ([edit-by-text.md](edit-by-text.md))

**Motion/composições**
- [ ] Frames do meio de cada cena (não do início da animação)

Falhou algum item: corrigir e rodar o QA de novo. No resumo da entrega, dizer o que foi conferido e o que não deu para conferir (ex.: "áudio medido, não ouvido").

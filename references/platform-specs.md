# Specs por plataforma

Fontes: Meta Ads Guide e creators.facebook.com, YouTube Help, guias de safe zone e loudness de 2026 (billo.app, adkit.so, forasoft.com). Plataformas mudam a UI com frequência: na dúvida, conferir o guia oficial antes de um lançamento grande.

## Formatos

| Destino | Proporção | Resolução | Duração | Observação |
|---|---|---|---|---|
| Reels (orgânico e anúncio) | 9:16 | 1080×1920 | anúncio até 90s; ideal 15-30s | áudio ligado ajuda; legenda sempre |
| Stories | 9:16 | 1080×1920 | até 60s por story | CTA "arrasta para cima" fica na base |
| Feed Instagram/Facebook | 4:5 | 1080×1350 | ideal 15-60s | 1:1 (1080×1080) ainda aceito |
| TikTok | 9:16 | 1080×1920 | ideal 15-60s | UI cobre base e lateral direita |
| YouTube Shorts | 9:16 | 1080×1920 | até 180s | UI cobre base e lateral direita |
| YouTube / VSL em página | 16:9 | 1920×1080 | livre | gerar também o gancho em 9:16 para anúncio |

Padrão técnico de export: H.264 (`libx264`), `yuv420p`, 30 fps, AAC 48 kHz estéreo, `-movflags +faststart`. Receitas em [ffmpeg-recipes.md](ffmpeg-recipes.md). Vídeo vindo da HeyGen sai em 25 fps: converter para 30 antes de montar junto com outro material.

## Safe zones (9:16, 1080×1920)

A interface do app cobre partes do vídeo. Texto, rosto e CTA ficam **dentro da área útil**:

| Destino | Topo livre | Base livre | Laterais |
|---|---|---|---|
| Reels | 270 px (14%) | 670 px (35%) | 65 px de cada lado |
| Stories | ~250 px | ~340 px | 65 px |
| TikTok / Shorts | ~250 px | ~600 px | direita ~150 px (botões) |

Área útil segura para todos: **x 65-930, y 270-1250**. Usar essa quando o mesmo vídeo vai para várias plataformas. Legenda no terço central dessa área ([captions.md](captions.md)).

No 4:5 e no 16:9 não há UI por cima, mas manter margem de 5% nas bordas.

## Áudio

- **Loudness**: -14 LUFS integrado, pico real -1 dBTP, LRA ~11. É o alvo de YouTube, Instagram, TikTok e Meta Ads. Medir e normalizar com `loudnorm` em duas passadas.
- Voz sempre acima da trilha: trilha ~18-24 dB abaixo da voz quando há fala.
- Desenhar para **som desligado**: tudo que importa também aparece escrito.

## Uma versão por proporção

Não esticar nem cortar no export final de qualquer jeito. Compor cada proporção pensando no enquadramento (rosto centrado, texto dentro da safe zone). Quando o material é um só (ex.: gravação 16:9), usar crop centrado no rosto ([clipping.md](clipping.md)) ou layout com faixa (vídeo em cima, título/legenda embaixo).

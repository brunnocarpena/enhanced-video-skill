#!/usr/bin/env bash
# QA de vídeo: formato, loudness e frames para conferência visual.
# Uso: qa.sh "/abs/video.mp4" [--destino=reels|stories|tiktok|shorts|feed|youtube] [--frames=6]
# Saída: relatório no terminal + PNGs em "<video>-qa/" (frame 0 + N espaçados).
# Em 9:16 desenha a área útil (safe zone) por cima dos frames.
set -euo pipefail

[ $# -ge 1 ] || { echo "Uso: $0 video.mp4 [--destino=reels] [--frames=6]" >&2; exit 1; }
VIDEO="$1"; shift
DESTINO=""; N=6
for a in "$@"; do
  case "$a" in
    --destino=*) DESTINO="${a#*=}" ;;
    --frames=*) N="${a#*=}" ;;
  esac
done
[ -f "$VIDEO" ] || { echo "Arquivo não encontrado: $VIDEO" >&2; exit 1; }
command -v ffprobe >/dev/null || { echo "ffprobe não encontrado (instalar ffmpeg)" >&2; exit 1; }

probe() { ffprobe -v error -select_streams "$1" -show_entries "$2" -of default=nw=1:nk=1 "$VIDEO" | head -1; }
W=$(probe v:0 stream=width); H=$(probe v:0 stream=height)
FPS=$(probe v:0 stream=avg_frame_rate); VCODEC=$(probe v:0 stream=codec_name)
PIX=$(probe v:0 stream=pix_fmt); ACODEC=$(probe a:0 stream=codec_name || true)
DUR=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$VIDEO")
FPS_DEC=$(awk -F/ '{ if ($2>0) printf "%.2f", $1/$2; else print $1 }' <<< "$FPS")

echo "== Formato =="
echo "Resolução: ${W}x${H}   fps: $FPS_DEC   vídeo: $VCODEC/$PIX   áudio: ${ACODEC:-SEM ÁUDIO}"
printf "Duração: %.2fs\n" "$DUR"

# Resolução esperada por destino
case "$DESTINO" in
  reels|stories|tiktok|shorts) ESP="1080x1920" ;;
  feed) ESP="1080x1350" ;;
  youtube|pv) ESP="1920x1080" ;;
  *) ESP="" ;;
esac
if [ -n "$ESP" ]; then
  [ "${W}x${H}" = "$ESP" ] && echo "OK resolução de $DESTINO ($ESP)" || echo "ATENÇÃO: $DESTINO espera $ESP"
fi
[ "$PIX" = "yuv420p" ] || echo "ATENÇÃO: pix_fmt $PIX (usar yuv420p)"

echo "== Áudio =="
if [ -n "${ACODEC:-}" ]; then
  TMPL=$(mktemp)
  ffmpeg -hide_banner -nostats -i "$VIDEO" -af loudnorm=I=-14:TP=-1:LRA=11:print_format=json -f null - 2>&1 \
    | awk '/^\{/,/^\}/' > "$TMPL" || true
  I=$(grep '"input_i"' "$TMPL" | sed 's/[^-0-9.]//g')
  TP=$(grep '"input_tp"' "$TMPL" | sed 's/[^-0-9.]//g')
  LRA=$(grep '"input_lra"' "$TMPL" | sed 's/[^-0-9.]//g')
  rm -f "$TMPL"
  echo "Loudness: ${I} LUFS   pico real: ${TP} dBTP   LRA: ${LRA}"
  awk -v i="$I" -v tp="$TP" 'BEGIN{
    if (i < -15 || i > -13) print "ATENÇÃO: alvo -14 LUFS (aceitável -15 a -13)"; else print "OK loudness";
    if (tp > -1) print "ATENÇÃO: pico real acima de -1 dBTP"; else print "OK pico real" }'
else
  echo "Sem faixa de áudio."
fi

echo "== Frames =="
OUT="${VIDEO%.*}-qa"; mkdir -p "$OUT"
VF="scale=540:-2"
if [ "$W" -gt 0 ] && [ $(( H * 9 )) -eq $(( W * 16 )) ]; then
  # Área útil comum a Reels/TikTok/Shorts em 1080x1920: x 65-930, y 270-1250 (escala proporcional)
  VF="drawbox=x=iw*65/1080:y=ih*270/1920:w=iw*865/1080:h=ih*980/1920:color=lime@0.9:t=4,$VF"
fi
ffmpeg -hide_banner -loglevel error -y -ss 0 -i "$VIDEO" -frames:v 1 -vf "$VF" "$OUT/frame-00-inicio.png"
for k in $(seq 1 "$N"); do
  T=$(awk -v d="$DUR" -v k="$k" -v n="$N" 'BEGIN{ printf "%.2f", d*k/(n+1) }')
  ffmpeg -hide_banner -loglevel error -y -ss "$T" -i "$VIDEO" -frames:v 1 -vf "$VF" "$OUT/frame-$(printf %02d "$k")-${T}s.png"
done
echo "Frames em: $OUT"
ls -1 "$OUT"
echo "Agora abrir os PNG e conferir o qa-checklist."

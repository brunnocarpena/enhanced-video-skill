#!/usr/bin/env bash
# Preflight: o que está disponível nesta máquina antes de escolher o caminho.
# Uso: check-tools.sh
# Não instala nada. Só relata e sugere o caminho grátis que funciona aqui.
set -uo pipefail

ok()   { printf "OK    %s\n" "$1"; }
falta(){ printf "FALTA %s\n" "$1"; }

echo "== ffmpeg =="
FF=""
for c in /usr/local/opt/ffmpeg-full/bin/ffmpeg /opt/homebrew/opt/ffmpeg-full/bin/ffmpeg "$(command -v ffmpeg 2>/dev/null)"; do
  [ -n "$c" ] && [ -x "$c" ] || continue
  FILTROS=$("$c" -hide_banner -filters 2>/dev/null)
  tem() { grep -qE "^ [A-Z.]+ +$1 " <<< "$FILTROS"; }
  L=""; for f in ass subtitles drawtext overlay loudnorm; do tem "$f" && L="$L $f"; done
  echo "$c ->${L:- nenhum filtro relevante}"
  if [ -z "$FF" ] || { tem ass && ! grep -q ass <<< "$FF_FILTROS"; }; then FF="$c"; FF_FILTROS="$L"; fi
done
if [ -z "$FF" ]; then
  falta "ffmpeg (obrigatório): brew install ffmpeg"
else
  echo "Usar: $FF"
  if grep -q " ass" <<< "$FF_FILTROS"; then
    ok "legenda .ass queimada pelo ffmpeg"
  else
    falta "ass/subtitles/drawtext neste ffmpeg (o ffmpeg do Homebrew vem sem libass/freetype)"
    echo "      Legenda e texto: usar HyperFrames, ou PNG transparente + filtro overlay (captions.md)."
    echo "      Opcional grátis: brew install ffmpeg-full (keg-only), depois de supply-chain-guard."
  fi
fi

echo "== Texto em PNG (legenda/título sem drawtext) =="
if command -v magick >/dev/null; then ok "ImageMagick $(magick -version | head -1 | awk '{print $3}') -> scripts/texto-png.py"
else falta "ImageMagick (brew install imagemagick) - sem ele, texto via HyperFrames ou Chromium headless"; fi

echo "== Transcrição =="
if command -v whisper-cli >/dev/null || command -v whisper-cpp >/dev/null; then ok "whisper.cpp"
elif command -v whisper >/dev/null; then ok "openai-whisper"
else falta "Whisper local (brew install whisper-cpp, ou uvx openai-whisper) - antes, supply-chain-guard"; fi

echo "== HyperFrames =="
if command -v npx >/dev/null; then
  ok "node $(node -v 2>/dev/null) (HyperFrames via npm exec --package=hyperframes@<versão pinada>)"
  MRA=$(npm config get min-release-age 2>/dev/null)
  [ -n "$MRA" ] && [ "$MRA" != "null" ] && [ "$MRA" != "undefined" ] && echo "      npm min-release-age=$MRA: pinar versão publicada há $MRA+ dias (hyperframes.md)"
else falta "node/npx"; fi
for b in "/Applications/Google Chrome.app" "/Applications/Brave Browser.app" "/Applications/Chromium.app"; do
  [ -d "$b" ] && { ok "navegador Chromium: $b"; break; }
done

echo "== Pago / cota =="
[ -n "${HEYGEN_API_KEY:-}" ] && echo "ATENÇÃO HEYGEN_API_KEY definida: ferramentas HeyGen podem usar a API PAGA" || ok "sem HEYGEN_API_KEY no ambiente"
command -v claude >/dev/null && { claude mcp list 2>/dev/null | grep -qi heygen && ok "MCP heygen registrado" || falta "MCP heygen (heygen.md, seção de instalação)"; }
Q="$(dirname "$0")/heygen-quota.sh"; [ -x "$Q" ] && "$Q" check 2>/dev/null
exit 0

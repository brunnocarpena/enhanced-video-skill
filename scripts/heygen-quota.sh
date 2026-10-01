#!/usr/bin/env bash
# Contador local da cota do HeyGen Free (3 vídeos/mês).
# Uso: heygen-quota.sh check | use | set N
# Arquivo: ~/.claude/enhanced-video/heygen-quota, uma linha "AAAA-MM N".
# É uma aproximação: a fonte de verdade é o painel da HeyGen.
set -euo pipefail

LIMITE=3
DIR="$HOME/.claude/enhanced-video"
ARQ="$DIR/heygen-quota"
MES=$(date +%Y-%m)

usados=0
if [ -f "$ARQ" ]; then
  read -r mes_arq n_arq < "$ARQ" || true
  if [ "${mes_arq:-}" = "$MES" ] && [[ "${n_arq:-}" =~ ^[0-9]+$ ]]; then
    usados=$n_arq
  fi
fi

gravar() { mkdir -p "$DIR"; echo "$MES $1" > "$ARQ"; }

case "${1:-check}" in
  check)
    restam=$(( LIMITE - usados )); [ $restam -lt 0 ] && restam=0
    echo "HeyGen Free: $usados de $LIMITE usados em $MES (restam $restam)"
    [ $restam -eq 0 ] && { echo "ESGOTADA: não gerar; oferecer o fallback grátis."; exit 2; }
    exit 0 ;;
  use)
    if [ $usados -ge $LIMITE ]; then
      echo "Cota já esgotada ($usados de $LIMITE em $MES). Nada registrado." >&2; exit 2
    fi
    gravar $(( usados + 1 ))
    echo "Registrado: $(( usados + 1 )) de $LIMITE em $MES" ;;
  set)
    n="${2:-}"
    [[ "$n" =~ ^[0-9]+$ ]] || { echo "Uso: $0 set N" >&2; exit 1; }
    gravar "$n"
    echo "Ajustado: $n de $LIMITE em $MES" ;;
  *)
    echo "Uso: $0 check | use | set N" >&2; exit 1 ;;
esac

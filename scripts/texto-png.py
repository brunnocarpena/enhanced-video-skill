#!/usr/bin/env python3
"""PNG transparente de legenda ou título, para sobrepor com o filtro overlay do ffmpeg.

Existe porque o ffmpeg do Homebrew vem sem drawtext/ass e o screenshot de Chromium
headless pode travar. Usa só o ImageMagick (`magick`), sem navegador e sem rede.

Uso:
  texto-png.py "O erro que todo iniciante comete" saida.png
  texto-png.py "a CALIBRAÇÃO leva menos" bloco-03.png --destaque calibração --caixa-alta
  texto-png.py "Curso de Radiestesia" cta.png --fundo "#FFD23F" --cor "#2A0B3D" --contorno none

A largura padrão (865 px) é a largura da área útil do 9:16 (x 65-930): o texto quebra
linha antes de sair dela. Posicionar no overlay com x=(W-w)/2 e y dentro de 270-1250.
"""
import argparse, os, subprocess, sys, tempfile

FONTE_PADRAO = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"


def magick(*args):
    subprocess.run(["magick", *args], check=True, stdin=subprocess.DEVNULL)


def tamanho(png):
    out = subprocess.run(["magick", "identify", "-format", "%w %h", png],
                         check=True, capture_output=True, text=True).stdout
    w, h = out.split()
    return int(w), int(h)


def palavra_png(p, cor, a, tmp, i):
    out = os.path.join(tmp, f"p{i}.png")
    base = ["-background", "none", "-font", a.fonte, "-pointsize", str(a.tamanho)]
    if a.contorno != "none" and a.borda > 0:
        # contorno embaixo e preenchimento por cima: o contorno não "come" a letra
        magick(*base, "-fill", a.contorno, "-stroke", a.contorno, "-strokewidth", str(a.borda), f"label:{p}",
               "(", *base, "-fill", cor, "-stroke", "none", f"label:{p}", ")",
               "-gravity", "center", "-compose", "over", "-composite", out)
    else:
        magick(*base, "-fill", cor, f"label:{p}", out)
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("texto")
    ap.add_argument("saida")
    ap.add_argument("--largura", type=int, default=865, help="largura máxima em px (padrão: área útil 9:16)")
    ap.add_argument("--tamanho", type=int, default=72, help="corpo da fonte em pt")
    ap.add_argument("--fonte", default=FONTE_PADRAO, help="caminho de .ttf/.otf com acentos")
    ap.add_argument("--cor", default="white")
    ap.add_argument("--destaque", default="", help="palavras com cor de destaque, separadas por vírgula")
    ap.add_argument("--cor-destaque", default="#FFD23F")
    ap.add_argument("--contorno", default="black", help="cor do contorno ou 'none'")
    ap.add_argument("--borda", type=int, default=10, help="espessura do contorno")
    ap.add_argument("--fundo", default="none", help="cor da caixa atrás do texto ou 'none'")
    ap.add_argument("--margem", type=int, default=28, help="respiro interno da caixa")
    ap.add_argument("--caixa-alta", action="store_true")
    a = ap.parse_args()

    if not os.path.exists(a.fonte):
        sys.exit(f"Fonte não encontrada: {a.fonte}")
    texto = a.texto.upper() if a.caixa_alta else a.texto
    norm = lambda s: s.strip(".,!?:;\"'").lower()
    destaques = {norm(d) for d in a.destaque.split(",") if d.strip()}
    pad = a.margem if a.fundo != "none" else 0
    limite = a.largura - 2 * pad
    espaco = max(8, a.tamanho * 3 // 10)

    with tempfile.TemporaryDirectory() as tmp:
        pals = []
        for i, p in enumerate(texto.split()):
            cor = a.cor_destaque if norm(p) in destaques else a.cor
            png = palavra_png(p, cor, a, tmp, i)
            pals.append((png, tamanho(png)[0]))

        linhas, atual, larg = [], [], 0
        for png, w in pals:
            novo = w if not atual else larg + espaco + w
            if atual and novo > limite:
                linhas.append(atual); atual, larg = [png], w
            else:
                atual.append(png); larg = novo
        if atual:
            linhas.append(atual)

        lpngs = []
        for j, ln in enumerate(linhas):
            out = os.path.join(tmp, f"l{j}.png")
            args = []
            for k, png in enumerate(ln):
                if k:
                    args += ["(", "-size", f"{espaco}x1", "xc:none", ")"]
                args.append(png)
            magick("-background", "none", *args, "-gravity", "center", "+append", out)
            if tamanho(out)[0] > limite:
                print(f"ATENÇÃO: uma palavra sozinha passa de {limite}px; reduzir --tamanho", file=sys.stderr)
            lpngs.append(out)

        bloco = os.path.join(tmp, "bloco.png")
        magick("-background", "none", *lpngs, "-gravity", "center", "-append", bloco)
        if a.fundo == "none":
            magick(bloco, a.saida)
        else:
            w, h = tamanho(bloco)
            W, H = w + 2 * pad, h + 2 * pad
            r = min(24, H // 4)
            magick("-size", f"{W}x{H}", "xc:none", "-fill", a.fundo,
                   "-draw", f"roundrectangle 0,0,{W-1},{H-1},{r},{r}",
                   bloco, "-gravity", "center", "-compose", "over", "-composite", a.saida)

    w, h = tamanho(a.saida)
    print(f"{a.saida} {w}x{h} ({len(linhas)} linha{'s' if len(linhas) > 1 else ''})")


if __name__ == "__main__":
    main()

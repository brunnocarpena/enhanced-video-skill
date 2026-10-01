# Trava de cota (HeyGen Free) e portão de aprovação

Ideia de portão de aprovação e estimativa antes de gerar inspirada no OpenMontage (AGPL): **só a ideia, nenhum código**.

## Por quê

O Free da HeyGen dá 3 vídeos por mês. Gastar um à toa (teste errado, roteiro que ia mudar) é perder 1/3 do mês. E o usuário já teve créditos queimados sem confirmação, então nada que consome cota ou dinheiro acontece no automático.

## Contador local

Arquivo `~/.claude/enhanced-video/heygen-quota`, uma linha: `AAAA-MM N` (ex.: `2026-10 1`). Mês diferente do atual = zerado.

```bash
~/.claude/skills/enhanced-video/scripts/heygen-quota.sh check   # "HeyGen Free: 1 de 3 usados em 2026-10 (restam 2)"
~/.claude/skills/enhanced-video/scripts/heygen-quota.sh use     # registra +1 depois de gerar
~/.claude/skills/enhanced-video/scripts/heygen-quota.sh set 2   # corrigir com o número do painel
```

O contador é uma aproximação: vídeos gerados direto no site não entram nele. A fonte de verdade é o painel da HeyGen. Se o usuário disser um número diferente, usar `set`.

## Portão (antes de cada geração)

1. Roteiro final aprovado pelo usuário (não gastar cota com rascunho; testar o texto em voz alta/legenda antes).
2. Rodar `check` e mostrar ao usuário, numa mensagem:
   - "Vai usar 1 vídeo da cota grátis: N+1 de 3 deste mês."
   - duração estimada (palavras ÷ 150 por minuto; tem que ser ≤ 1 min) e caracteres (≤ 5.000);
   - avatar e voz que serão usados;
   - aviso de que o rosto/voz vão para a HeyGen, se for de cliente.
3. Esperar o ok explícito. Silêncio ou "vai fazendo" de outra tarefa não vale.
4. Gerar. Ao confirmar que o vídeo foi criado, rodar `use` e anotar no `project.md`.
5. Falhou do lado da HeyGen sem gerar vídeo: não rodar `use`; conferir no painel se consumiu.

## Cota esgotada (3 de 3)

Não chamar a HeyGen. Oferecer o fallback grátis de [heygen.md](heygen.md) (gravação no celular pelo pipeline local, ou vídeo sem rosto). Pagar só se o usuário pedir explicitamente → [paid-on-request.md](paid-on-request.md).

## Armadilha

Se existir `HEYGEN_API_KEY` no ambiente, ferramentas da HeyGen podem usar a API (paga) em vez do MCP do plano Free, sem avisar. Antes de gerar, conferir `[ -n "$HEYGEN_API_KEY" ] && echo "atenção: HEYGEN_API_KEY definida"` e, se estiver, perguntar ao usuário se é para usar a API paga.

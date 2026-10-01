# Regras da casa (BMC Mídia) aplicadas a vídeo

Vencem qualquer outra reference.

## Texto na tela
- **PT-BR com acentuação correta** em legenda, título, CTA e nome de arquivo exibido. Conferir "você", "não", "página", "é" antes do render. Fonte que desloca acento (ex.: Cormorant Garamond no Remotion) é trocada; Lora, DM Sans, Montserrat, Poppins e Inter renderizam bem.
- **Hífen, nunca travessão** ("-", não "—"/"–") em qualquer texto visível.
- **Sem palavra órfã**: quebrar linhas de legenda/título à mão se sobrar uma palavra sozinha.
- **Nada de número inventado** ("+10 mil alunos") se não veio do cliente.

## Custo e cota
- Tudo gratuito por padrão. Pago só com pedido explícito + custo mostrado + ok ([paid-on-request.md](paid-on-request.md)).
- HeyGen Free: 3 vídeos/mês, confirmar cada um ([quota-guard.md](quota-guard.md)).

## Segredos
- Chave/token nunca pelo chat e nunca como flag de CLI. Criar `.env.local` com a variável vazia e comentário de onde obter, conferir `git check-ignore -v .env.local`, usar via env var.

## Ambiente do Mac
- **Rodar CLIs de Node a partir do `$HOME`** quando o projeto está em `~/Documents`: o macOS dá `EPERM uv_cwd`. Passar caminhos absolutos (e `--public-dir` no Remotion).
- `.nvmrc` = 22 nos projetos de vídeo em Node (o Node 25+ quebra alguns builds).
- Nunca matar navegador por nome. Render headless que travar: matar só pelo PID que a própria sessão capturou.

## Entrega
- `open -R "<arquivo>"` ao terminar e o caminho absoluto em texto puro.
- Trabalho novo nunca sobrescreve versão anterior: `v2`, `v3` em arquivos separados.
- Pastas por lançamento da Mari: `lancamento-gratuito/<sigla>` e `lancamento-pago/<nome>`; vídeo fica junto do lançamento a que pertence.

## Cliente
- Esten Works: nunca citar impressão 3D, filamento, camadas ou PLA.
- Clube dos Pendulados: gênero neutro ("embaixador" masculino genérico).
- Rosto/voz de cliente indo para terceiro (HeyGen etc.) exige autorização do cliente.

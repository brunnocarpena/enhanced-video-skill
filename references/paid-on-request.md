# Pago - só sob pedido explícito

> Fontes consultadas em 01/10/2026 (read-only):
> - https://help.heygen.com/en/articles/10060327-heygen-api-pricing-explained - API sem crédito grátis desde fev/2026; créditos valem 12 meses
> - https://www.heygen.com/pricing - planos pagos
> - https://developers.heygen.com/mcp/overview.md - tools que gastam crédito
> - https://github.com/heygen-com/skills - prioridade API key x MCP
> - https://ai.google.dev/gemini-api/docs/pricing - Veo 3.1
> - https://docs.dev.runwayml.com/guides/pricing/ - Runway
> - Skill local `~/.agents/skills/higgsfield-generate` - CLI e `generate cost`
> - Valores marcados **(verificar)** vieram de fonte não oficial ou não estavam na página oficial.

**Este arquivo só é lido quando o usuário pede, com todas as letras, uma ferramenta paga** ("usa a API da HeyGen", "gera no Veo", "pode gastar crédito do Higgsfield"). "Faz um vídeo bonito" não é pedido de pago: seguir no grátis.

## Regra única para tudo abaixo

1. **Estimar antes**: duração x preço unitário (fórmula em cada seção) e, quando a ferramenta tem comando de estimativa, rodar ele.
2. **Mostrar ao usuário** numa mensagem só: ferramenta, modelo, duração, resolução, **custo estimado em US$ e/ou créditos**, saldo atual se der para ler, e quantas tentativas cabem.
3. **Esperar confirmação explícita** ("pode", "manda"). Silêncio ou "ok, vê aí" sobre outra coisa não vale.
4. **Refazer é nova cobrança**: nova estimativa, nova confirmação. Nunca entrar em loop de tentativas.
5. Gerar **uma** peça curta de teste antes de lote. Lote só com confirmação do total.
6. Registrar no `project.md`: ferramenta, custo estimado, custo real, data.
7. Respeitar o teto de créditos das regras globais: na dúvida sobre escopo, parar e perguntar.

**Chaves**: só em `.env.local` do projeto (conferir `git check-ignore -v .env.local` antes), com a variável vazia e um comentário dizendo onde gerar. **Nunca pedir chave pelo chat. Nunca passar chave como flag de CLI** (`--api-key ...` fica no histórico e no `ps`): carregar como variável de ambiente só no comando, sem ecoar (`set -a; . ./.env.local; set +a`). Nunca `cat` do `.env.local`.

## HeyGen API (carteira pré-paga)

- **O que faz**: o mesmo que o MCP (avatar, Video Agent, tradução, lip-sync), mas cobrado numa **carteira separada** em US$, independente do plano web. Necessária para automação e para passar dos limites do Free sem assinar plano.
- **Custo**: desde **fev/2026 não há crédito grátis de API** (help.heygen.com). Pay-as-you-go em US$, varia por engine e duração; créditos **expiram em 12 meses**. Valores de fonte secundária **(verificar no painel: app.heygen.com/developers/api?modal=pricing)**: recarga mínima US$ 5; avatar padrão ~US$ 1/min; Avatar IV ~US$ 3-6/min; tradução e Video Agent ~US$ 2/min.
- **Estimar**: minutos de saída x preço do engine. VSL de 4 min em Avatar IV ≈ US$ 12-24.
- **Limites**: 10 fluxos simultâneos no pay-as-you-go; 5.000 caracteres por roteiro; 25 fps em vídeo com avatar; estourou o rate limit = `429` com `Retry-After` (esperar, não insistir).
- **Ao estourar o saldo**: a geração falha até recarregar (não há cobrança automática descrita) **(verificar)**.
- **Chave**: `HEYGEN_API_KEY` no `.env.local`.
- **Armadilha**: as HeyGen Skills usam a API **sempre que `HEYGEN_API_KEY` existir no ambiente**, mesmo com o MCP conectado. Chave exportada no shell = Free vira pago sem aviso. Nunca exportar no `~/.zshrc`; carregar só no comando pago.

## HeyGen planos pagos (web + MCP)

- Creator US$ 29/mês (600 créditos), Pro US$ 49/mês (1.000), Business US$ 149/mês (1.500 + US$ 20/assento), Enterprise sob consulta (heygen.com/pricing, 01/10/2026). Quantos créditos cada minuto de vídeo consome não está na página **(verificar)**.
- Com plano pago, o MCP desconta dos créditos do plano. O quota-guard deixa de ser "3 por mês" e passa a ser "custa X créditos de Y": ler saldo no painel e confirmar.
- Assinar plano é decisão do usuário e do cliente; a skill nunca assina nem sugere sem pedido.

## HeyGen AI Clipping

- **O que faz**: corta vídeo longo (live, aula) em clipes curtos automaticamente (`create_ai_clipping`).
- **Custo**: gasta crédito (mcp/overview). Free tem só "limited trial access"; custo por minuto não publicado **(verificar)**.
- **Alternativa grátis padrão**: corte local com Whisper + ffmpeg ([clipping.md](clipping.md)). Só usar AI Clipping se o usuário pedir.
- Envia a gravação inteira do cliente para a HeyGen: exige autorização do cliente.

## Render na nuvem do HyperFrames

- **O que faz**: sobe o bundle do projeto HyperFrames e a HeyGen renderiza ("no infrastructure to run").
- **Custo**: por minuto de saída, ~US$ 0,10/min em 1080p/30fps até ~US$ 0,30/min em 4K/60fps (fonte secundária) **(verificar na doc de Cloud Rendering)**. Cobrança provavelmente na carteira de API **(verificar)**.
- **Quando faz sentido**: quase nunca. Render local é grátis e determinístico. Só se a máquina não aguentar (4K longo) e o usuário pedir.

## Higgsfield (vídeo/imagem generativa: Kling, Veo, Sora, Seedance etc.)

- **Estado na máquina**: CLI em `/usr/local/bin/higgsfield`; skills instaladas (`higgsfield`, `higgsfield-generate`, `higgsfield-soul-id`, `higgsfield-product-photoshoot`, `higgsfield-marketplace-cards`). **Falta `higgsfield auth login`** - é interativo, quem roda é o usuário.
- **O que faz**: B-roll e cenas geradas por IA, foto de produto, personagem consistente (Soul ID).
- **Custo**: planos mensais com créditos; nomes e valores variam entre fontes (de ~US$ 9/mês com 120 créditos a ~US$ 129/mês com 3.000) **(verificar em higgsfield.ai/pricing, logado)**. Custo por geração depende do modelo, duração e resolução.
- **Estimar** (não gasta): `higgsfield generate cost <modelo> ...` e, para workflow, `higgsfield generate cost workflow <nome> --duration 8 --resolution 720p`. Saldo/sessão: `higgsfield account status`.
- **Ao estourar**: a geração não roda sem crédito; compra de pacote extra é decisão do usuário **(verificar comportamento)**.
- **Conflito com a skill instalada**: a `higgsfield-generate` diz para *não* estimar custo antes e manda instalar a CLI com `curl ... | sh`. **Aqui vale a regra da casa**: sempre rodar `generate cost` e esperar ok; nunca rodar instalador sem `supply-chain-guard`.

## Veo (Google, via Gemini API)

- **Custo** (ai.google.dev, 01/10/2026), **sem free tier** para Veo, por segundo gerado:
  - Veo 3.1: US$ 0,40/s (720p/1080p), US$ 0,60/s (4K)
  - Veo 3.1 Fast: US$ 0,10/s (720p), US$ 0,12/s (1080p), US$ 0,30/s (4K)
  - Veo 3.1 Lite: US$ 0,05/s (720p), US$ 0,08/s (1080p)
- **Estimar**: segundos x preço. 8 s de Veo 3.1 1080p = US$ 3,20; o mesmo no Fast = US$ 0,96.
- Só cobra se o vídeo for gerado com sucesso (doc oficial).
- **Ao estourar**: depende do billing do projeto Google Cloud; sem saldo/limite a chamada falha **(verificar)**. Sugerir ao usuário um orçamento com alerta no Google Cloud antes do primeiro uso.
- **Chave**: `GEMINI_API_KEY` no `.env.local`.

## Kling (API oficial)

- **Custo** (fonte secundária citando a página oficial, agosto/2026) **(verificar em klingai.com)**: Kling 3.0 ~US$ 0,084/s (720p sem áudio), ~US$ 0,112/s (720p com áudio ou 1080p sem), ~US$ 0,14/s (1080p com áudio), ~US$ 0,42/s (4K). 10 s em 1080p com áudio ≈ US$ 1,40. A API oficial vende em pacotes com mínimo **(verificar)**.
- Também acessível pelo Higgsfield (créditos do plano) - comparar com `higgsfield generate cost` antes.
- **Chave**: par access key + secret no `.env.local` **(verificar nomes)**.

## Runway (API)

- **Custo** (docs.dev.runwayml.com, 01/10/2026): crédito a **US$ 0,01**; `gen4.5` 12 créditos/s (US$ 0,12/s), `gen4_turbo` 5/s (US$ 0,05/s), `act_two` 5/s, `veo3.1_fast` sem áudio 10/s. Sem crédito grátis citado; recarga mínima não informada **(verificar)**.
- **Estimar**: segundos x créditos/s x US$ 0,01. 10 s de gen4_turbo = 50 créditos = US$ 0,50.
- **Chave**: `RUNWAYML_API_SECRET` no `.env.local`.

## Quadro rápido para mostrar ao usuário

```
Ferramenta: <nome / modelo>
Saída: <N s> em <resolução>, <proporção>
Custo estimado: US$ <x> (<y> créditos) - fonte: <comando ou tabela, data>
Saldo atual: <se der para ler>
Tentativas incluídas: 1 (refazer = nova confirmação)
Mídia do cliente enviada a terceiro: sim/não (autorização: <ok/pendente>)
Confirma?
```

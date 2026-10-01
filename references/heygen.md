# HeyGen - plano Free via MCP oficial

> Fontes consultadas em 01/10/2026 (read-only):
> - https://www.heygen.com/pricing - limites do Free
> - https://developers.heygen.com/mcp/overview.md - tools do MCP e quais gastam crédito
> - https://developers.heygen.com/mcp/claude-code.md - comando de instalação
> - https://developers.heygen.com/docs/usage-limits.md - 5.000 caracteres, 25 fps, proporções
> - https://developers.heygen.com/docs/avatar-consent.md - consentimento ao vivo, link de 24h
> - https://developers.heygen.com/skills/heygen-avatar.md e https://github.com/heygen-com/skills - `AVATAR-<NOME>.md`, MCP x API key
> - https://help.heygen.com/en/articles/10060327-heygen-api-pricing-explained - API sem crédito grátis desde fev/2026
>
> O que a doc não confirmou está marcado **(verificar)**. Preços e limites mudam: reconferir na fonte se a data acima tiver mais de 3 meses.

Este arquivo cobre só o caminho **grátis**: conta web no plano Free + MCP remoto com OAuth. Não usa chave de API. Qualquer coisa paga (API, plano pago, AI Clipping além do teste, render na nuvem) fica em [paid-on-request.md](paid-on-request.md).

## 1. Limites do Free (conferido em 01/10/2026 em heygen.com/pricing)

| Item | Limite |
|---|---|
| Vídeos | **3 por mês** |
| Duração | **até 1 min** por vídeo |
| Resolução | **até 1080p** |
| Avatar próprio | **1 Custom Video Avatar** |
| Avatares de banco | 500+ stock avatars |
| Idiomas | "30+ languages" |
| Avatar IV, Video Agent, tradução com lip-sync | "limited trial access" - quantidade não informada **(verificar)** |
| Marca d'água | remoção de marca d'água não aparece no Free; assumir que o vídeo sai com marca d'água **(verificar no primeiro vídeo)** |
| Dia em que a cota zera | não informado; o contador local usa o mês do calendário **(verificar no painel)** |

- O MCP remoto "is available on all HeyGen plans" e "does not cost extra": a geração desconta da cota do plano web, não de uma carteira de API (mcp/overview).
- A doc do Claude Code pede "a HeyGen account with Video Agent access". Se a conta Free não tiver, as tools de Video Agent falham; usar `create_video` **(verificar)**.
- Quando a cota estoura, a doc não diz o que acontece (bloqueio ou oferta de upgrade) **(verificar)**. Regra da casa: não chegar lá. O quota-guard (seção 6) para antes.

**Estourou ou vai estourar?** Não sugerir upgrade. Oferecer o fallback grátis (seção 6). Plano pago só se o usuário pedir, e aí vale [paid-on-request.md](paid-on-request.md).

## 2. Conectar o MCP oficial no Claude Code

Antes de tudo: rodar a skill **`supply-chain-guard`** (é um MCP novo; mesmo sendo remoto e oficial, a regra vale).

Comando oficial (rodar no terminal, fora do Claude Code). Escopo user, para valer em todos os projetos:

```bash
claude mcp add --transport http -s user heygen https://mcp.heygen.com/mcp/v1/
```

Só neste projeto: o mesmo sem `-s user`.

Depois:
1. **Reiniciar o Claude Code** - servidor MCP novo só aparece após reiniciar.
2. Dentro do Claude Code, rodar `/mcp` e escolher `heygen`: abre o OAuth no navegador. Fazer login na **conta HeyGen do cliente certo** (ou da agência) e aprovar. Sem chave de API, nada vai para `.env.local`.
3. Conferir: `claude mcp list` ou `/mcp` deve mostrar `heygen` como `connected`.
4. Teste sem custo: chamar `get_current_user` e `list_voices`.

Sessão não interativa não consegue fazer o OAuth: avisar o usuário para rodar `/mcp` numa sessão interativa.

### Tools expostas (nomes reais da doc) e custo

**Gastam crédito/cota** (segundo mcp/overview) - toda chamada passa pelo quota-guard:
`create_video`, `create_video_agent`, `generate_from_template`, `create_video_translation`, `create_ai_clipping`, `create_lipsync`, `create_avatar_looks`, `create_model_video`, `create_filler_word_removal`, `clone_voice`, `create_model_audio_voice`.

Atenção: `send_video_agent_message` dentro de uma sessão de Video Agent pode disparar nova geração; tratar como pago **(verificar)**. As versões em lote (`create_video_batch`, `create_lipsync_batch`, `create_video_translation_batch`) também geram vídeo: **não usar no Free**.

**Leitura e organização** (sem custo, pela doc):
`get_current_user`, `list_videos`, `get_video`, `get_video_scenes`, `delete_video`, `list_templates`, `get_template`, `list_voices`, `get_voice`, `list_avatar_groups`, `get_avatar_group`, `list_avatar_looks`, `get_avatar_look`, `list_look_templates`, `list_video_agent_styles`, `list_video_agent_sessions`, `get_video_agent_session`, `list_video_agent_session_videos`, `list_video_translation_languages`, `search_audio_sounds`, `list_assets`, `create_asset_upload`, `complete_asset_upload`, `get_asset`, `create_folder`, `get_folder`, `list_brand_kits`, `list_brand_glossaries`.

Criação de avatar: `create_avatar` e `create_avatar_consent` (seção 4). A doc não lista `create_avatar` como cobrado, mas no Free ele ocupa o **único** avatar próprio: confirmar com o usuário antes.

`create_speech`, `design_voice` e `generate_model_speech` não aparecem na lista de cobrados **(verificar)**; `generate_model_speech` tem limite de 30 requisições/min por membro.

## 3. Fluxo: vídeo de avatar com roteiro

1. **Roteiro pronto e cronometrado** (etapa 1 da skill). Free = até 1 min, o que dá ~130-150 palavras em pt-BR falado.
2. **Limite de 5.000 caracteres** por roteiro de avatar (usage-limits). No Free o limite de 1 min aperta antes. Roteiro maior (VSL): dividir em blocos fechados em fim de frase, um vídeo por bloco, e montar no pipeline local. Cada bloco gasta 1 da cota: mostrar a conta antes ("VSL em 3 blocos = 3 de 3 do mês").
3. **Avatar**: `list_avatar_groups` → `list_avatar_looks`. Preferir o avatar do cliente (`AVATAR-<NOME>.md`, seção 4); sem ele, um stock avatar coerente com o público.
4. **Voz pt-BR**: `list_voices` e filtrar por idioma Portuguese / locale pt-BR (não pt-PT). Ouvir a prévia antes. Anotar o `voice_id` no `project.md`.
5. **Formato**: 9:16 (Reels, Stories, anúncio) ou 16:9 (VSL, YouTube) - são as duas proporções da doc. Resolução 1080p (teto do Free). Uma proporção por vídeo: gerar as duas custa 2 da cota; preferir gerar uma e reenquadrar no pipeline local quando der.
6. **Quota-guard** (seção 6) → ok do usuário → `create_video`.
7. **Acompanhar** com `get_video` até concluir; baixar o MP4 pela URL retornada para a pasta do trabalho (`curl -L -o avatar-v1.mp4 "<url>"`). A URL pode expirar: baixar logo **(verificar validade)**.
8. **25 fps**: vídeo com avatar sai em 25 fps (usage-limits). Se for montar com material em 30 fps (HyperFrames, B-roll, celular), converter antes, para não dar engasgo:
   ```bash
   ffmpeg -i avatar-v1.mp4 -vf "fps=30" -c:v libx264 -crf 18 -preset slow -c:a copy avatar-v1-30fps.mp4
   ```
   Se o vídeo final for só o avatar com legenda, pode manter 25 fps.
9. **Seguir no pipeline local**: legenda palavra a palavra ([captions.md](captions.md)), loudness -14 LUFS / -1 dBTP ([ffmpeg-recipes.md](ffmpeg-recipes.md)), QA de frames ([qa-checklist.md](qa-checklist.md)). Legenda e trilha **sempre local**, nunca pelas tools pagas da HeyGen.

## 4. Avatar personalizado (digital twin)

O Free permite **1** avatar próprio. Escolher bem de quem é (normalmente o expert principal do cliente).

**Consentimento** (avatar-consent):
- Quem grava é **a própria pessoa do avatar**, ao vivo, pela webcam, na página de consentimento hospedada pela HeyGen.
- O link é gerado por `create_avatar_consent` e **vale 24 horas**. Expirou: gerar outro.
- A frase pode ser lida em português ("can be in any language").
- Conferir depois em `get_avatar_group` se o `consent_status` foi aprovado.
- Consentimento pré-gravado é só Enterprise. Não dá para a agência gravar no lugar do cliente.

**Antes de mandar o link**, a agência providencia um **termo de uso de imagem e voz** assinado pelo cliente: para que o avatar será usado, por quanto tempo, quem pode gerar vídeos com ele e como pedir a exclusão (`delete_avatar_group`). Sem termo assinado, não criar.

**Documentar cada avatar** num `AVATAR-<NOME>.md` na raiz do projeto do cliente (padrão das HeyGen Skills, que leem esse arquivo):

```markdown
# AVATAR-MARI
## Aparência
idade, cabelo, estilo, roupa de referência
## Voz
tom, sotaque (pt-BR), energia, uma analogia de uma linha
## HeyGen
- Group ID: <id estável - nunca muda>
- Voice ID / Voice Name:
- Looks: landscape=<...> portrait=<...> square=<...>
- Consentimento: aprovado em AAAA-MM-DD
- Termo de imagem: <onde está o PDF assinado>
- Last Synced: <ISO>
```

O `look_id` é efêmero: sempre resolver de novo a partir do Group ID na hora de gerar.

## 5. pt-BR e lip-sync

- A página de marketing diz que há lip-sync em Português e vozes pt-BR. A **doc de desenvolvedor não garante** qualidade de lip-sync em pt-BR para avatar com roteiro **(verificar)**.
- **Primeiro uso com um avatar/voz = teste**: roteiro curto (10-15 s) com palavras difíceis (nasais "ão", "ões", "lh", "nh", números e nome do produto). Isso gasta 1 da cota: avisar.
- Pronúncia errada de marca/termo: reescrever foneticamente no roteiro (ex.: "Hotmart" → "Rót-mart") e registrar no `AVATAR-<NOME>.md`.
- Voz clonada (`clone_voice`) está na lista de cobrados: no Free, usar voz de banco **(verificar se o Free inclui clonagem)**.

## 6. Quota-guard (obrigatório antes de qualquer tool que gasta)

Contador local em `~/.claude/enhanced-video/heygen-quota` (uma linha `AAAA-MM N`), mantido pelo script. Detalhes e armadilha da `HEYGEN_API_KEY`: [quota-guard.md](quota-guard.md).

```bash
~/.claude/skills/enhanced-video/scripts/heygen-quota.sh check   # antes; sai com código 2 se 3/3
~/.claude/skills/enhanced-video/scripts/heygen-quota.sh use     # depois que a HeyGen aceitou a geração
```

1. Mostrar ao usuário: **"vai usar N+1 de 3 deste mês"** + o que será gerado (avatar, voz, proporção, duração estimada).
2. **Esperar ok explícito.** Refazer conta como nova geração e pede ok de novo.
3. Só depois da geração aceita pela HeyGen: `heygen-quota.sh use`.
4. O contador é aproximação local. Em caso de dúvida, conferir no painel da HeyGen; o painel manda. Registrar no `project.md` ("HeyGen: N de 3 em AAAA-MM").

**Com 3/3: não chamar a HeyGen.** Oferecer o fallback grátis:
- **Expert gravando no celular** (roteiro + teleprompter grátis, luz de janela, 9:16) → pipeline local: corte de silêncio ([edit-by-text.md](edit-by-text.md)), legenda, motion de apoio em HyperFrames.
- **Vídeo sem rosto**: texto animado + B-roll + **narração gravada pelo cliente** (áudio de celular serve), montado em HyperFrames.
- Ou esperar a virada do mês. Plano pago/API só se o usuário pedir ([paid-on-request.md](paid-on-request.md)).

## 7. Privacidade

- Enviar **rosto, voz ou gravação do cliente** para a HeyGen (avatar, `create_asset_upload`, tradução, lip-sync) é mandar dado pessoal para um terceiro nos EUA. **Exige autorização do cliente**, de preferência no mesmo termo de imagem. Avisar isso no brief antes de qualquer upload.
- Stock avatar + roteiro sem dado pessoal não precisa dessa autorização.
- Não subir para a HeyGen material de aluno ou de terceiro que apareça no vídeo.
- Pedido de exclusão do cliente: `delete_video`, `delete_asset`, `delete_avatar_group` e anotar a data no `AVATAR-<NOME>.md`.
- Conta HeyGen errada no OAuth = vídeo do cliente na conta de outro. Conferir com `get_current_user` antes de gerar.

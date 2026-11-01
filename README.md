# Planilha do Luen

Saldo dia a dia, previsão de diário, horizonte de meses e patrimônio.
Dados no Supabase, sincronizados entre computador e celular.

```
/            versão completa (desktop): grade + painéis + patrimônio
/app         versão mobile, instalável como PWA
```

## Antes de publicar

Preencha as chaves do Supabase nos **dois** arquivos:

- `index.html`
- `app/index.html`

Procure no começo do script:

```javascript
const SUPABASE_URL      = "COLE_AQUI_A_URL";
const SUPABASE_ANON_KEY = "COLE_AQUI_A_CHAVE_ANON";
```

Os valores estão em Project Settings → API, no painel do Supabase.

## Publicar

1. Crie um repositório no GitHub e suba estes arquivos
2. Em vercel.com → Add New → Project → importe o repositório
3. Framework Preset: **Other**. Sem build, sem output directory
4. Deploy

Cada `git push` republica automaticamente.

## Instalar no celular

Abra `seu-endereco.vercel.app/app` no Chrome do Android:
menu → **Adicionar à tela de início**.

No iPhone, Safari → botão compartilhar → **Adicionar à Tela de Início**.

O ícone abre em tela cheia, sem barra de navegador.

## Faturas do cartão

Rode `faturas_cartao.sql` no SQL Editor do Supabase (uma vez). Ele liga cada
cartão a uma tag — os cartões que já existem ficam ligados à tag de mesmo nome.

- **Desktop:** painel *faturas do cartão* ao lado da grade. Digite o valor e
  aperte Enter (pula para o próximo cartão). Apagar o valor remove a fatura do mês.
- **Celular:** menu → *faturas do cartão*, toque no cartão e digite o valor.

A fatura é um lançamento de saída com a tag do cartão, no dia do vencimento.
Se já existe um lançamento assim no mês, ele é atualizado em vez de duplicado.
Com a fatura informada, as assinaturas daquele cartão param de descontar à
parte (já estão dentro da fatura) e aparecem como *na fatura*.

## Tags, assinaturas e patrimônio

Rode `remodelagem.sql` no SQL Editor (uma vez). Ele adiciona o limite mensal
das tags e a meta de patrimônio.

- **Tags** são categorias: a aba *tags* (desktop e celular) mostra quanto saiu
  em cada uma no mês, a fatia do gasto total, a comparação com o mês anterior
  e, se a tag tiver limite, quanto já foi usado. Tags ligadas a um cartão
  aparecem em *cartões*. Toque/clique numa tag para ver os lançamentos dela.
- **Assinaturas previstas** aparecem na grade com o valor tracejado (roxo).
  Clicar nelas abre *confirmar que caiu* ou *editar assinatura*.
- **Patrimônio**: gráfico de evolução do líquido com a variação de cada mês,
  meta com prazo (quanto falta, quanto guardar por mês, quando chega no ritmo
  atual) e, no celular, menu → *patrimônio* para atualizar os valores do mês.

## Cartões, previsão por categoria e metas

Rode `cartoes_metas.sql` no SQL Editor (uma vez).

- **Cartões** (aba no desktop; menu → *cartões* no celular): cada cartão mostra a
  fatura do mês — *prevista* pela soma das cobranças (assinaturas, mensalidades)
  ou *informada* com o valor real —, o checklist das cobranças para marcar
  quando aparecerem na fatura e a previsão dos próximos meses. Na grade, as
  cobranças viram uma linha só: *Fatura Nubank (prevista)* no vencimento.
- **Previsão por categoria**: cada item (cabeleireiro, saúde, jantares…) aponta
  para uma tag. No mês atual, o que já foi gasto com a tag abate da previsão e
  o saldo projeta só o restante. A aba *tags* tem o quadro previsto × real mês a mês.
- **Metas de patrimônio**: várias, cada uma *juntar* (numa conta ou no
  líquido) ou *quitar* (abater parte de uma dívida), com prazo.
- O painel lateral da aba saldos mostra só os bens; dívidas ficam na aba patrimônio.
- O seletor de data é um calendário e permite lançar em outro mês.

## Compras no cartão e tags nos cálculos

Rode `compras_cartao.sql` no SQL Editor (uma vez).

- **Compras no cartão**: no *adicionar*, escolha o tipo *cartão* e o cartão.
  A compra aparece na coluna *cartão* da grade, mas não mexe no saldo do dia:
  ela soma na fatura certa, decidida pelo **dia de fechamento** do cartão
  (comprou no fechamento ou depois → fatura seguinte). Sem fechamento
  cadastrado, usamos 7 dias antes do vencimento.
- **Parcelado**: divide o valor em N parcelas mensais (no cartão, cada parcela
  cai numa fatura). Também vale para lançamentos comuns.
- *Cartão + repetir mensalmente* vira uma cobrança fixa do cartão.
- **Tags**: em *onde esta tag entra nos cálculos* (desktop) ou *configurações
  avançadas* (celular), cada área pode ser *ignorar* ou *calcular*: saldos,
  performance, economizado, custo de vida e diário médio.

## Segurança

A chave anon é pública por natureza — quem protege os dados é o RLS,
que exige login. Ainda assim, desligue o cadastro aberto:

**Authentication → Providers → Email → desmarque *Enable sign up***

Sem isso, qualquer visitante poderia criar conta no seu projeto (não veria
seus dados, mas ocuparia espaço).

## Offline

O service worker guarda a casca do app (HTML, ícones, biblioteca).
Abrindo sem internet, a interface carrega — mas os dados vêm do Supabase,
então lançamentos novos só entram quando a conexão voltar.

O pontinho no cabeçalho fica vermelho quando está sem conexão.

## Atualizar

Editou algo? `git push`. O Vercel republica em segundos.

Se o celular continuar mostrando a versão antiga, é o cache do service
worker: troque `financeira-v1` por `financeira-v2` no topo de `app/sw.js`
para forçar a renovação.

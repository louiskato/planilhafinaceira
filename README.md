# Central Financeira

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

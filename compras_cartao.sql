-- ═══════════════════════════════════════════════════════════
-- COMPRAS NO CARTÃO
-- Cada compra (ou parcela) vira uma linha. Ela não desconta do saldo
-- no dia: soma na fatura do cartão, escolhida pelo dia de fechamento.
-- Rode no SQL Editor (uma vez; pode repetir sem problema).
-- ═══════════════════════════════════════════════════════════

create table if not exists public.compras_cartao (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users on delete cascade,
  cartao_id  uuid not null references public.cartoes on delete cascade,
  data       date not null,                       -- dia da compra (ou da parcela)
  valor      numeric(12,2) not null check (valor > 0),
  nome       text,
  tag_id     uuid references public.tags on delete set null,
  parcela    int,                                 -- 1, 2, 3… (null = à vista)
  parcelas   int,                                 -- total de parcelas
  grupo      uuid,                                -- liga as parcelas da mesma compra
  created_at timestamptz not null default now()
);
create index if not exists compras_cartao_user_data_idx on public.compras_cartao (user_id, data);
create index if not exists compras_cartao_grupo_idx on public.compras_cartao (grupo);

alter table public.compras_cartao enable row level security;
drop policy if exists "sel_compras" on public.compras_cartao;
drop policy if exists "ins_compras" on public.compras_cartao;
drop policy if exists "upd_compras" on public.compras_cartao;
drop policy if exists "del_compras" on public.compras_cartao;
create policy "sel_compras" on public.compras_cartao
  for select using (auth.uid() = user_id);
create policy "ins_compras" on public.compras_cartao
  for insert with check (auth.uid() = user_id);
create policy "upd_compras" on public.compras_cartao
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "del_compras" on public.compras_cartao
  for delete using (auth.uid() = user_id);

-- atualização em tempo real entre celular e computador
do $$ begin
  alter publication supabase_realtime add table public.compras_cartao;
exception when duplicate_object then null; end $$;

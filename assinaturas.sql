-- ═══════════════════════════════════════════════════════════
-- ASSINATURAS PREVISTAS — valores que VÃO cair mas ainda não caíram.
-- É previsão (sombra no saldo), não lançamento. Ao confirmar num mês,
-- vira lançamento real SÓ naquele mês, sem afetar os outros.
-- Rode no SQL Editor depois do schema principal.
-- ═══════════════════════════════════════════════════════════

-- a assinatura em si (a regra de previsão)
create table public.assinaturas (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users on delete cascade,
  nome        text not null,
  valor       numeric(12,2) not null check (valor > 0),
  tipo        text not null default 'saida' check (tipo in
              ('entrada','saida','economia','diario')),
  dia         int check (dia between 1 and 31),   -- dia previsto da fatura (opcional)
  tag_id      uuid references public.tags on delete set null,
  ativa       boolean not null default true,
  ordem       int not null default 0,
  created_at  timestamptz not null default now()
);
create index assinaturas_user_idx on public.assinaturas (user_id, ativa);

-- confirmações: registra que a assinatura X caiu no mês Y (vira lançamento real)
create table public.assinaturas_confirmadas (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users on delete cascade,
  assinatura_id uuid not null references public.assinaturas on delete cascade,
  ano           int not null,
  mes           int not null,
  lancamento_id uuid references public.lancamentos on delete set null,
  created_at    timestamptz not null default now(),
  unique (assinatura_id, ano, mes)
);
create index assinaturas_conf_idx on public.assinaturas_confirmadas (user_id, ano, mes);

alter table public.assinaturas enable row level security;
alter table public.assinaturas_confirmadas enable row level security;

create policy "sel_assinaturas" on public.assinaturas
  for select using (auth.uid() = user_id);
create policy "ins_assinaturas" on public.assinaturas
  for insert with check (auth.uid() = user_id);
create policy "upd_assinaturas" on public.assinaturas
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "del_assinaturas" on public.assinaturas
  for delete using (auth.uid() = user_id);

create policy "sel_assin_conf" on public.assinaturas_confirmadas
  for select using (auth.uid() = user_id);
create policy "ins_assin_conf" on public.assinaturas_confirmadas
  for insert with check (auth.uid() = user_id);
create policy "upd_assin_conf" on public.assinaturas_confirmadas
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "del_assin_conf" on public.assinaturas_confirmadas
  for delete using (auth.uid() = user_id);

alter publication supabase_realtime add table public.assinaturas;
alter publication supabase_realtime add table public.assinaturas_confirmadas;

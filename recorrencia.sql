-- ═══════════════════════════════════════════════════════════
-- RECORRÊNCIAS — regras que geram lançamentos sob demanda
-- Rode no SQL Editor depois do schema principal.
-- ═══════════════════════════════════════════════════════════

create table public.recorrencias (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users on delete cascade,
  tipo        text not null check (tipo in
              ('entrada','saida','economia','diario')),
  valor       numeric(12,2) not null check (valor > 0),
  nome        text,
  tag_id      uuid references public.tags on delete set null,
  frequencia  text not null check (frequencia in
              ('mensalmente','semanalmente','diariamente')),
  -- para mensal: dia do mês (1-31). para semanal: dia da semana (0=dom..6=sáb).
  -- para diária: ignorado.
  dia_ref     int,
  data_inicio date not null,
  data_fim    date,                -- null = sem fim (mas a UI sempre define)
  ativa       boolean not null default true,
  created_at  timestamptz not null default now()
);
create index recorrencias_user_idx on public.recorrencias (user_id, ativa);

alter table public.recorrencias enable row level security;
create policy "sel_recorrencias" on public.recorrencias
  for select using (auth.uid() = user_id);
create policy "ins_recorrencias" on public.recorrencias
  for insert with check (auth.uid() = user_id);
create policy "upd_recorrencias" on public.recorrencias
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "del_recorrencias" on public.recorrencias
  for delete using (auth.uid() = user_id);

alter publication supabase_realtime add table public.recorrencias;

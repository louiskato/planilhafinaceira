-- ═══════════════════════════════════════════════════════════
-- PREVISÃO POR CATEGORIA + METAS DE PATRIMÔNIO
-- Rode no SQL Editor (uma vez; pode repetir sem problema).
-- ═══════════════════════════════════════════════════════════

-- cada item da previsão aponta para uma tag (a categoria)
alter table public.previsao_itens
  add column if not exists tag_id uuid references public.tags on delete set null;

-- liga os itens que já existem à tag de mesmo nome, se houver
update public.previsao_itens p
   set tag_id = t.id
  from public.tags t
 where p.tag_id is null
   and t.user_id = p.user_id
   and lower(trim(t.nome)) = lower(trim(p.nome));

-- várias metas: juntar (numa conta ou no líquido) ou quitar parte de uma dívida
create table if not exists public.metas_patrimonio (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users on delete cascade,
  nome          text not null,
  tipo          text not null default 'juntar' check (tipo in ('juntar','quitar')),
  conta_id      uuid references public.patrimonio_contas on delete cascade,  -- null = patrimônio líquido
  valor_alvo    numeric(14,2) not null check (valor_alvo >= 0),  -- juntar: valor final; quitar: saldo devedor alvo
  valor_inicial numeric(14,2),                                   -- quitar: saldo devedor quando a meta foi criada
  prazo         date,
  ordem         int not null default 0,
  created_at    timestamptz not null default now()
);
create index if not exists metas_patrimonio_user_idx on public.metas_patrimonio (user_id, ordem);

alter table public.metas_patrimonio enable row level security;
drop policy if exists "sel_metas_pat" on public.metas_patrimonio;
drop policy if exists "ins_metas_pat" on public.metas_patrimonio;
drop policy if exists "upd_metas_pat" on public.metas_patrimonio;
drop policy if exists "del_metas_pat" on public.metas_patrimonio;
create policy "sel_metas_pat" on public.metas_patrimonio
  for select using (auth.uid() = user_id);
create policy "ins_metas_pat" on public.metas_patrimonio
  for insert with check (auth.uid() = user_id);
create policy "upd_metas_pat" on public.metas_patrimonio
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "del_metas_pat" on public.metas_patrimonio
  for delete using (auth.uid() = user_id);

-- traz a meta única antiga (preferencias) como a primeira meta, se ainda não houver metas
insert into public.metas_patrimonio (user_id, nome, tipo, valor_alvo, prazo)
select p.user_id, 'patrimônio líquido', 'juntar', p.meta_patrimonio, p.meta_patrimonio_prazo
  from public.preferencias p
 where p.meta_patrimonio is not null
   and not exists (select 1 from public.metas_patrimonio m where m.user_id = p.user_id);

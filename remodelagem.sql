-- ═══════════════════════════════════════════════════════════
-- REMODELAGEM — tags como categoria + meta de patrimônio
-- Rode no SQL Editor (uma vez; pode repetir sem problema).
-- ═══════════════════════════════════════════════════════════

-- limite mensal opcional por tag (orçamento da categoria)
alter table public.tags
  add column if not exists limite_mensal numeric(12,2)
  check (limite_mensal is null or limite_mensal > 0);

-- meta de patrimônio líquido, com prazo opcional (guardado como dia 1 do mês)
alter table public.preferencias
  add column if not exists meta_patrimonio numeric(14,2)
  check (meta_patrimonio is null or meta_patrimonio > 0);
alter table public.preferencias
  add column if not exists meta_patrimonio_prazo date;

-- a coluna tags.areas continua existindo, mas o app não usa mais
-- (as "configurações avançadas" nunca chegaram a afetar os cálculos)

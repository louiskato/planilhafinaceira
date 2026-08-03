-- ═══════════════════════════════════════════════════════════
-- CARTÕES COM VENCIMENTO + VÍNCULO DAS ASSINATURAS
-- Cada assinatura cai no dia de vencimento do seu cartão.
-- (A tabela cartoes já existe no schema; só vinculamos as assinaturas.)
-- Rode no SQL Editor.
-- ═══════════════════════════════════════════════════════════

-- vincula cada assinatura a um cartão (opcional: null = usa o dia próprio)
alter table public.assinaturas
  add column if not exists cartao_id uuid references public.cartoes on delete set null;

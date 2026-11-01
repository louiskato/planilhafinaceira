-- ═══════════════════════════════════════════════════════════
-- FATURAS DO CARTÃO — vínculo cartão ↔ tag
-- Cada cartão aponta para uma tag (ex.: cartão Nubank ↔ tag Nubank).
-- A fatura do mês é o lançamento de saída com essa tag; a área
-- "faturas do cartão" atualiza esse valor rapidamente.
-- Rode no SQL Editor.
-- ═══════════════════════════════════════════════════════════

alter table public.cartoes
  add column if not exists tag_id uuid references public.tags on delete set null;

-- vincula os cartões que já existem à tag de mesmo nome, se houver
update public.cartoes c
   set tag_id = t.id
  from public.tags t
 where c.tag_id is null
   and t.user_id = c.user_id
   and lower(trim(t.nome)) = lower(trim(c.nome));

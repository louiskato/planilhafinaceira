-- ═══════════════════════════════════════════════════════════
-- "PLANILHA ATUALIZADA ATÉ" — o dia até onde tudo já foi lançado
-- Guardado nas preferências para valer no celular e no computador.
-- Rode no SQL Editor (uma vez; pode repetir sem problema).
-- ═══════════════════════════════════════════════════════════

alter table public.preferencias
  add column if not exists atualizado_ate date;

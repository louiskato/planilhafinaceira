-- ═══════════════════════════════════════════════════════════
-- DIA DE VENCIMENTO DA FATURA
-- Todas as assinaturas previstas caem neste dia (fatura do cartão).
-- Rode no SQL Editor.
-- ═══════════════════════════════════════════════════════════

alter table public.preferencias
  add column if not exists venc_fatura int
  check (venc_fatura is null or venc_fatura between 1 and 31);

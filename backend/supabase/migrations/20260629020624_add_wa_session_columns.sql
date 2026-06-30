-- Menambahkan kolom-kolom untuk menyimpan state WA Bot
ALTER TABLE public.wa_sessions
ADD COLUMN IF NOT EXISTS satker TEXT,
ADD COLUMN IF NOT EXISTS judul TEXT,
ADD COLUMN IF NOT EXISTS deskripsi TEXT;

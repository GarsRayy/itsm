-- ============================================================
-- ITSM Service Catalog & Smart WhatsApp Bot Schema
-- ============================================================

-- ── 1. USER PROFILES (Client Registry) ─────────────────────
-- Diisi oleh Admin via UI atau CSV import (Fase 2).
-- Bot akan mencocokkan kolom `phone_number` dengan `sender` dari Fonnte.
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name     text NOT NULL,
  phone_number  text NOT NULL UNIQUE,  -- format: 628xxxxxxxxx
  division      text,
  email         text,
  employee_id   text,
  is_active     boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

-- ── 2. SERVICE CATALOG (11 Layanan Utama) ───────────────────
CREATE TABLE IF NOT EXISTS public.service_catalog (
  id           integer PRIMARY KEY,
  code         text NOT NULL UNIQUE,   -- misal: LI.01.01
  name         text NOT NULL,          -- misal: Layanan Jaringan Intranet
  provider     text NOT NULL,          -- misal: LI - Layanan Infrastruktur
  status       text NOT NULL DEFAULT 'production',
  display_order integer NOT NULL DEFAULT 0
);

-- ── 3. SERVICE ITEMS (51 Sub-Kategori) ──────────────────────
CREATE TABLE IF NOT EXISTS public.service_items (
  id           integer PRIMARY KEY,
  catalog_id   integer NOT NULL REFERENCES public.service_catalog(id) ON DELETE CASCADE,
  code         text NOT NULL UNIQUE,   -- misal: LI-01.01.1
  name         text NOT NULL,          -- misal: Pemasangan jaringan intranet
  request_type text NOT NULL,          -- 'service request' | 'incident'
  status       text NOT NULL DEFAULT 'production'
);

-- ── 4. WA SESSIONS (State Mesin Percakapan Bot) ─────────────
-- Menyimpan "di mana" posisi pengguna saat ini dalam alur percakapan.
-- Dibersihkan otomatis setelah 24 jam tidak aktif.
CREATE TABLE IF NOT EXISTS public.wa_sessions (
  phone_number  text PRIMARY KEY,
  state         text NOT NULL DEFAULT 'idle',
  -- state: 'idle' | 'awaiting_service' | 'awaiting_subcat' | 'awaiting_description'
  catalog_id    integer REFERENCES public.service_catalog(id),
  item_id       integer REFERENCES public.service_items(id),
  profile_id    uuid REFERENCES public.user_profiles(id),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

-- ── 5. TAMBAHKAN KOLOM BARU KE TICKETS ──────────────────────
ALTER TABLE public.tickets
  ADD COLUMN IF NOT EXISTS user_profile_id uuid REFERENCES public.user_profiles(id),
  ADD COLUMN IF NOT EXISTS service_item_id integer REFERENCES public.service_items(id),
  ADD COLUMN IF NOT EXISTS request_type    text,
  ADD COLUMN IF NOT EXISTS resolution_note text;

-- ── 6. SEED: SERVICE CATALOG (11 Layanan Utama) ─────────────
INSERT INTO public.service_catalog (id, code, name, provider, display_order) VALUES
  (1,  'LI.01.01',  'Layanan Jaringan Intranet',                            'LI - Layanan Infrastruktur', 1),
  (2,  'LI.PTRH.01','Jaringan Intranet Operasional Peltar (SCADA System)',   'LI - Layanan Infrastruktur', 2),
  (3,  'LI.PTRH.02','Surveillance System (CCTV)',                            'LI - Layanan Infrastruktur', 3),
  (4,  'LI.PTRH.03','Layanan Komputer/Laptop',                               'LI - Layanan Infrastruktur', 4),
  (5,  'LI.PTRH.04','Layanan Internet',                                      'LI - Layanan Infrastruktur', 5),
  (6,  'LI.PTRH.05','Layanan Server',                                        'LI - Layanan Infrastruktur', 6),
  (7,  'LI.PTRH.06','Automasi, Monitoring dan Keamanan',                     'LI - Layanan Infrastruktur', 7),
  (8,  'LP.PTRH.01','Perangkat Pendukung Komputer',                          'LP - Layanan Pendukung',     8),
  (9,  'LP.PTRH.02','Sarana Teknologi Rapat Daring',                         'LP - Layanan Pendukung',     9),
  (10, 'LP.PTRH.03','Support Layanan Aplikasi PTBA (eskalasi)',              'LP - Layanan Pendukung',     10),
  (11, 'LP.PTRH.04','Administrasi',                                          'LP - Layanan Pendukung',     11)
ON CONFLICT (id) DO NOTHING;

-- ── 7. SEED: SERVICE ITEMS (51 Sub-Kategori) ────────────────
INSERT INTO public.service_items (id, catalog_id, code, name, request_type) VALUES
  -- LI.01.01 – Layanan Jaringan Intranet (catalog_id=1)
  (1,  1, 'LI-01.01.1', 'Pemasangan jaringan intranet',               'service request'),
  (2,  1, 'LI-01.01.2', 'Pemindahan jaringan intranet',               'service request'),
  (3,  1, 'LI-01.01.3', 'Pemutusan jaringan intranet',                'service request'),
  (4,  1, 'LI-01.01.4', 'Perapihan jaringan intranet',                'service request'),
  (5,  1, 'LI-01.01.5', 'Penanganan gangguan/insiden',                'incident'),

  -- LI.PTRH.01 – Jaringan Intranet SCADA (catalog_id=2)
  (6,  2, 'LI.PTRH.01.01', 'Pemasangan jaringan intranet',            'service request'),
  (7,  2, 'LI.PTRH.01.02', 'Pemindahan jaringan intranet',            'service request'),
  (8,  2, 'LI.PTRH.01.03', 'Pemutusan jaringan intranet',             'service request'),
  (9,  2, 'LI.PTRH.01.04', 'Perapihan jaringan intranet',             'service request'),
  (10, 2, 'LI.PTRH.01.05', 'Penanganan gangguan/insiden',             'incident'),

  -- LI.PTRH.02 – CCTV (catalog_id=3)
  (11, 3, 'LI.PTRH.02.01', 'Pemasangan CCTV',                        'service request'),
  (12, 3, 'LI.PTRH.02.02', 'Pemindahan CCTV',                        'service request'),
  (13, 3, 'LI.PTRH.02.03', 'Penonaktifan CCTV',                      'service request'),
  (14, 3, 'LI.PTRH.02.04', 'Permintaan hasil rekaman CCTV',          'service request'),
  (15, 3, 'LI.PTRH.02.05', 'Penanganan gangguan/insiden CCTV',       'incident'),

  -- LI.PTRH.03 – Komputer/Laptop (catalog_id=4)
  (16, 4, 'LI.PTRH.03.01', 'Pemasangan PC/laptop',                   'service request'),
  (17, 4, 'LI.PTRH.03.02', 'Pemindahan PC/laptop',                   'service request'),
  (19, 4, 'LI.PTRH.03.04', 'Penanganan gangguan/insiden PC/laptop',  'incident'),
  (23, 4, 'LI.PTRH.03.03', 'Penarikan PC/laptop',                    'service request'),

  -- LI.PTRH.04 – Internet (catalog_id=5)
  (36, 5, 'LI.PTRH.04.01', 'Permintaan akses Internet',              'service request'),
  (37, 5, 'LI.PTRH.04.02', 'Penanganan gangguan/insiden Internet',   'incident'),

  -- LI.PTRH.05 – Server (catalog_id=6)
  (43, 6, 'LI.PTRH.05.01', 'Layanan Pengelolaan Fisik Server',               'service request'),
  (44, 6, 'LI.PTRH.05.02', 'Pengelolaan Virtualisasi dan Kontainerisasi',    'service request'),
  (45, 6, 'LI.PTRH.05.03', 'Pengelolaan Penyimpanan Server',                 'service request'),
  (46, 6, 'LI.PTRH.05.04', 'Pengelolaan backup dan pemulihan',               'service request'),
  (51, 6, 'LI.PTRH.05.05', 'Penanganan gangguan server',                     'incident'),

  -- LI.PTRH.06 – Automasi, Monitoring, Keamanan (catalog_id=7)
  (47, 7, 'LI.PTRH.06.01', 'Network Monitoring System (NMS)',         'service request'),
  (48, 7, 'LI.PTRH.06.02', 'Platform Sistem Keamanan (SIEM)',        'service request'),
  (49, 7, 'LI.PTRH.06.03', 'Layanan Automasi',                       'service request'),
  (50, 7, 'LI.PTRH.06.04', 'Pengelolaan Firewall',                   'service request'),
  (52, 7, 'LI.PTRH.06.05', 'Penanganan gangguan/insiden',            'incident'),

  -- LP.PTRH.01 – Perangkat Pendukung Komputer (catalog_id=8)
  (20, 8, 'LP.PTRH.01.01', 'Pemasangan perangkat pendukung komputer',          'service request'),
  (21, 8, 'LP.PTRH.01.02', 'Pemindahan perangkat pendukung komputer',          'service request'),
  (22, 8, 'LP.PTRH.01.03', 'Penarikan perangkat pendukung komputer',           'service request'),
  (24, 8, 'LP.PTRH.01.04', 'Penanganan gangguan/insiden perangkat pendukung',  'service request'),

  -- LP.PTRH.02 – Sarana Rapat Daring (catalog_id=9)
  (25, 9, 'LP.PTRH.02.01A', 'Layanan dukungan rapat internal',       'service request'),
  (26, 9, 'LP.PTRH.02.01B', 'Layanan dukungan rapat eksternal',      'service request'),

  -- LP.PTRH.03 – Support Aplikasi PTBA (catalog_id=10)
  (27, 10, 'LP.PTRH.03.01', 'Eskalasi kendala Cisea modul Executive Support', 'incident'),
  (28, 10, 'LP.PTRH.03.02', 'Eskalasi kendala Cisea modul Supply Chain',      'incident'),
  (29, 10, 'LP.PTRH.03.03', 'Eskalasi kendala Cisea modul SDM',               'incident'),
  (30, 10, 'LP.PTRH.03.04', 'Eskalasi kendala Cisea modul Finance & Accounting','incident'),
  (31, 10, 'LP.PTRH.03.05', 'Eskalasi kendala Cisea modul Corporate Services', 'incident'),
  (32, 10, 'LP.PTRH.03.06', 'Eskalasi kendala Email',                           'incident'),
  (33, 10, 'LP.PTRH.03.07', 'Eskalasi kendala Directory access',                'incident'),
  (34, 10, 'LP.PTRH.03.08', 'Eskalasi kendala ERP',                             'incident'),
  (35, 10, 'LP.PTRH.03.09', 'Eskalasi layanan Aplikasi PTBA lainnya',           'incident'),

  -- LP.PTRH.04 – Administrasi (catalog_id=11)
  (38, 11, 'LP.PTRH.04.01', 'Procurement',         'service request'),
  (39, 11, 'LP.PTRH.04.02', 'Administrasi Kontrak', 'service request'),
  (40, 11, 'LP.PTRH.04.03', 'Laporan Bulanan',      'service request'),
  (41, 11, 'LP.PTRH.04.04', 'Audit',                'service request'),
  (42, 11, 'LP.PTRH.04.05', 'Sharing Knowledge',    'service request')
ON CONFLICT (id) DO NOTHING;

-- ── 8. ROW LEVEL SECURITY ─────────────────────────────────────
ALTER TABLE public.user_profiles  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_items   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wa_sessions     ENABLE ROW LEVEL SECURITY;

-- Katalog bisa dibaca semua authenticated user
DROP POLICY IF EXISTS "catalog_read" ON public.service_catalog;
CREATE POLICY "catalog_read" ON public.service_catalog FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "items_read" ON public.service_items;
CREATE POLICY "items_read"   ON public.service_items   FOR SELECT TO authenticated USING (true);

-- User profiles: leader bisa baca semua, executor hanya milik sendiri (enforce di app layer)
DROP POLICY IF EXISTS "profiles_service_role_all" ON public.user_profiles;
CREATE POLICY "profiles_service_role_all" ON public.user_profiles FOR ALL TO service_role USING (true);

DROP POLICY IF EXISTS "sessions_service_role_all" ON public.wa_sessions;
CREATE POLICY "sessions_service_role_all" ON public.wa_sessions   FOR ALL TO service_role USING (true);

-- ============================================================
-- Phase 2 & 3: Ticket Lifecycle & Assignment Schema Updates
-- ============================================================

-- ── 1. ADD RESOLVED_AT TIMESTAMP ─────────────────────────────
ALTER TABLE public.tickets
  ADD COLUMN IF NOT EXISTS resolved_at timestamptz,
  ADD COLUMN IF NOT EXISTS assignee_name text,
  ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

-- ── 2. INDEX FOR PERFORMANCE ─────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_tickets_status ON public.tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_assignee ON public.tickets(assignee_name);
CREATE INDEX IF NOT EXISTS idx_tickets_source ON public.tickets(source);
CREATE INDEX IF NOT EXISTS idx_tickets_created_at ON public.tickets(created_at DESC);

-- ── 3. RLS POLICIES FOR AUTHENTICATED USERS ──────────────────
-- Allow authenticated users to read all tickets
DROP POLICY IF EXISTS "tickets_read_all" ON public.tickets;
CREATE POLICY "tickets_read_all"
  ON public.tickets FOR SELECT
  TO authenticated
  USING (true);

-- Allow authenticated users to update tickets (status changes, assignments)
DROP POLICY IF EXISTS "tickets_update_all" ON public.tickets;
CREATE POLICY "tickets_update_all"
  ON public.tickets FOR UPDATE
  TO authenticated
  USING (true);

-- Allow authenticated users to insert tickets (manual creation from app)
DROP POLICY IF EXISTS "tickets_insert_auth" ON public.tickets;
CREATE POLICY "tickets_insert_auth"
  ON public.tickets FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Allow service_role full access (for Edge Functions / bot)
DROP POLICY IF EXISTS "tickets_service_role_all" ON public.tickets;
CREATE POLICY "tickets_service_role_all"
  ON public.tickets FOR ALL
  TO service_role
  USING (true);

-- ── 4. USER PROFILES: Allow authenticated read ───────────────
DROP POLICY IF EXISTS "profiles_read_auth" ON public.user_profiles;
CREATE POLICY "profiles_read_auth"
  ON public.user_profiles FOR SELECT
  TO authenticated
  USING (true);

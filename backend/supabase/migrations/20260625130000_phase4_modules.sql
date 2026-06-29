-- ============================================================
-- Phase 4: Change, Problem, and Project Management
-- ============================================================

-- ENUMS
CREATE TYPE public.change_status AS ENUM ('planned_and_scheduled', 'approved', 'implemented', 'monitored', 'closed');
CREATE TYPE public.problem_status AS ENUM ('under_investigation', 'known_error', 'resolved', 'closed');
CREATE TYPE public.project_status AS ENUM ('planning', 'active', 'on_hold', 'completed');

-- ── 1. CHANGES TABLE ─────────────────────────────
CREATE TABLE IF NOT EXISTS public.changes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  change_ref text UNIQUE NOT NULL,
  title text NOT NULL,
  subclass text NOT NULL, -- Normal Change, Routine Change
  organization text,
  start_date timestamptz,
  end_date timestamptz,
  status change_status NOT NULL DEFAULT 'planned_and_scheduled',
  assignee_name text,
  description text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- ── 2. PROBLEMS TABLE ─────────────────────────────
CREATE TABLE IF NOT EXISTS public.problems (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  problem_ref text UNIQUE NOT NULL,
  title text NOT NULL,
  root_cause text,
  workaround text,
  status problem_status NOT NULL DEFAULT 'under_investigation',
  assignee_name text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- ── 3. PROJECTS TABLE ─────────────────────────────
CREATE TABLE IF NOT EXISTS public.projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_ref text UNIQUE NOT NULL,
  title text NOT NULL,
  description text,
  start_date timestamptz,
  end_date timestamptz,
  status project_status NOT NULL DEFAULT 'planning',
  manager_name text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- ── 4. RLS POLICIES ─────────────────────────────
ALTER TABLE public.changes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.problems ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users full access for now (RBAC can be refined later)
CREATE POLICY "changes_all_auth" ON public.changes FOR ALL TO authenticated USING (true);
CREATE POLICY "problems_all_auth" ON public.problems FOR ALL TO authenticated USING (true);
CREATE POLICY "projects_all_auth" ON public.projects FOR ALL TO authenticated USING (true);

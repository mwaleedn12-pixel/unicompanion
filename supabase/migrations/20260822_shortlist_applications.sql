-- ============================================================
-- Module 34: Application Tracker (Real)
-- Module 35: Shortlist Manager
-- Run this in the Supabase SQL editor for project gdgctotikklntfmepwiw
-- Note: supabase_service.dart already had userShortlist / userApplications
-- getters scaffolded pointing at these table names — this migration creates them.
-- ============================================================

-- ── user_shortlist ──
create table if not exists public.user_shortlist (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  university_id uuid not null references public.universities(id) on delete cascade,
  notes text,
  created_at timestamptz not null default now(),
  unique (user_id, university_id)
);

-- ── user_applications ──
create table if not exists public.user_applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  university_id uuid not null references public.universities(id) on delete cascade,
  program_name text,
  status text not null default 'interested'
    check (status in ('interested', 'preparing', 'applied', 'test_taken', 'interview', 'selected', 'rejected', 'withdrawn')),
  deadline date,
  applied_date date,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ── Indexes ──
create index if not exists idx_user_shortlist_user on public.user_shortlist(user_id);
create index if not exists idx_user_applications_user on public.user_applications(user_id);
create index if not exists idx_user_applications_deadline on public.user_applications(deadline);

-- ── Row Level Security ──
alter table public.user_shortlist enable row level security;
alter table public.user_applications enable row level security;

create policy "Users manage own shortlist" on public.user_shortlist
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Users manage own applications" on public.user_applications
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
-- Run this in Supabase SQL Editor after creating exactly two Auth users.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique check (username ~ '^[a-z0-9_-]{3,24}$'),
  display_name text not null,
  role text not null check (role in ('owner','member')),
  couple_id uuid not null
);
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  couple_id uuid not null,
  created_by uuid not null references auth.users(id),
  question text not null check (char_length(question) between 1 and 500),
  task_date date not null,
  created_at timestamptz not null default now()
);
create table if not exists public.responses (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  couple_id uuid not null,
  completed boolean not null default false,
  answer text not null default '',
  note text not null default '',
  updated_at timestamptz not null default now(),
  unique(task_id,user_id)
);

create or replace function public.my_couple_id() returns uuid
language sql stable security definer set search_path=public
as $$ select couple_id from public.profiles where id=auth.uid() $$;
create or replace function public.is_couple_owner() returns boolean
language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.profiles where id=auth.uid() and role='owner') $$;
grant execute on function public.my_couple_id() to authenticated;
grant execute on function public.is_couple_owner() to authenticated;

grant select on public.profiles to authenticated;
grant select,insert on public.tasks to authenticated;
grant select,insert,update on public.responses to authenticated;
alter table public.profiles enable row level security;
alter table public.tasks enable row level security;
alter table public.responses enable row level security;

drop policy if exists "members can view own couple profiles" on public.profiles;
create policy "members can view own couple profiles" on public.profiles for select to authenticated using (couple_id=public.my_couple_id());
drop policy if exists "members can view couple tasks" on public.tasks;
create policy "members can view couple tasks" on public.tasks for select to authenticated using (couple_id=public.my_couple_id());
drop policy if exists "only owner creates tasks" on public.tasks;
create policy "only owner creates tasks" on public.tasks for insert to authenticated with check (couple_id=public.my_couple_id() and created_by=auth.uid() and public.is_couple_owner());
drop policy if exists "members can view couple responses" on public.responses;
create policy "members can view couple responses" on public.responses for select to authenticated using (couple_id=public.my_couple_id());
drop policy if exists "users create own response" on public.responses;
create policy "users create own response" on public.responses for insert to authenticated with check (user_id=auth.uid() and couple_id=public.my_couple_id() and exists(select 1 from public.tasks t where t.id=task_id and t.couple_id=public.my_couple_id()));
drop policy if exists "users update own response" on public.responses;
create policy "users update own response" on public.responses for update to authenticated using (user_id=auth.uid() and couple_id=public.my_couple_id()) with check (user_id=auth.uid() and couple_id=public.my_couple_id());

-- Next: in Authentication > Users, create exactly two users with these emails:
-- kayo@mustayo.app and mustafa@mustayo.app. Use strong passwords and disable email confirmation for this private alias-based setup.
-- Copy their Auth user UUIDs into the profile inserts below. Use ONE shared random UUID as couple_id.
-- Replace all placeholders before running these inserts:
-- insert into public.profiles(id,username,display_name,role,couple_id) values
-- ('KAYO_AUTH_USER_UUID','kayo','Kayo','owner','SHARED_COUPLE_UUID'),
-- ('MUSTAFA_AUTH_USER_UUID','mustafa','Mustafa','member','SHARED_COUPLE_UUID');

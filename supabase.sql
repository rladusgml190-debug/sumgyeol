-- 숨결: 바다가 데려간 근심 누적 숫자 (글 내용은 저장하지 않음)
create table if not exists public.sea (
  id smallint primary key default 1 check (id = 1),
  total bigint not null default 0,
  updated_at timestamptz not null default now()
);
insert into public.sea (id, total) values (1, 0) on conflict (id) do nothing;
alter table public.sea enable row level security;
drop policy if exists "anyone can read the count" on public.sea;
create policy "anyone can read the count" on public.sea for select to anon, authenticated using (true);

create or replace function public.release_worry()
returns bigint language sql security definer set search_path = public as $$
  update public.sea set total = total + 1, updated_at = now() where id = 1 returning total;
$$;
revoke all on function public.release_worry() from public;
grant execute on function public.release_worry() to anon, authenticated;

do $$ begin
  alter publication supabase_realtime add table public.sea;
exception when duplicate_object then null; end $$;

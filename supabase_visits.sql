-- 숨결: 방문 통계 (익명 번호와 행동 종류만, 이름·글 내용 없음)
create table if not exists public.events (
  id bigint generated always as identity primary key,
  at timestamptz not null default now(),
  kind text not null check (kind in ('visit','start','finish','release')),
  visitor text not null check (length(visitor) between 6 and 40)
);
create index if not exists events_at_idx on public.events (at);
alter table public.events enable row level security;

create or replace function public.log_event(p_kind text, p_visitor text)
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_kind = 'visit' and exists (
    select 1 from public.events where visitor = p_visitor and kind = 'visit' and at > now() - interval '30 minutes'
  ) then return; end if;
  insert into public.events (kind, visitor) values (p_kind, p_visitor);
end $$;
revoke all on function public.log_event(text, text) from public;
grant execute on function public.log_event(text, text) to anon, authenticated;

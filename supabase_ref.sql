-- 숨결: 유입 경로(ref) 기록 — 링크의 ?ref= 값 또는 이전 사이트 도메인만 저장
alter table public.events add column if not exists ref text check (ref is null or length(ref) <= 30);

create or replace function public.log_event(p_kind text, p_visitor text, p_ref text default null)
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_kind = 'visit' and exists (
    select 1 from public.events where visitor = p_visitor and kind = 'visit' and at > now() - interval '30 minutes'
  ) then return; end if;
  insert into public.events (kind, visitor, ref)
  values (p_kind, p_visitor, nullif(left(lower(regexp_replace(coalesce(p_ref, ''), '[^a-zA-Z0-9._-]', '', 'g')), 30), ''));
end $$;
drop function if exists public.log_event(text, text);
revoke all on function public.log_event(text, text, text) from public;
grant execute on function public.log_event(text, text, text) to anon, authenticated;

-- 채널별 방문자 (최근 7일)
-- select coalesce(ref, '직접') as 경로, count(distinct visitor) as 방문자
-- from public.events where kind = 'visit' and at > now() - interval '7 days'
-- group by 1 order by 2 desc;

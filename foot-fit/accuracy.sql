-- Arc accuracy check: app numbers vs. the size people really wear (numbers only, no names or photos)
create table if not exists public.foot_accuracy (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  side text check (side in ('left','right')),
  method text check (char_length(method) <= 20),
  app_length real check (app_length between 100 and 400),
  app_ball real check (app_ball between 40 and 200),
  app_instep real check (app_instep between 0 and 200),
  app_size real check (app_size between 100 and 400),
  actual_size real check (actual_size between 100 and 400),
  tape_length real check (tape_length between 100 and 400),
  tape_ball real check (tape_ball between 40 and 200),
  tape_instep real check (tape_instep between 0 and 200),
  toe_shape text check (char_length(toe_shape) <= 20),
  measured_hour smallint check (measured_hour between 0 and 23),
  check (actual_size is not null or tape_length is not null)
);
alter table public.foot_accuracy enable row level security;
drop policy if exists "anyone can add a check" on public.foot_accuracy;
create policy "anyone can add a check" on public.foot_accuracy for insert to anon, authenticated with check (true);
drop policy if exists "anyone can read checks" on public.foot_accuracy;
create policy "anyone can read checks" on public.foot_accuracy for select to anon, authenticated using (true);
grant select, insert on public.foot_accuracy to anon, authenticated;

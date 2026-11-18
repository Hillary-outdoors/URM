-- URMA · step 30 · Conditions that come in more than one
--
-- The day sheet had one box each for weather events, avalanche, river levels and closures. Real
-- days are not like that: two warnings at once, a different avalanche rating at each elevation
-- band, four rivers all reading differently, three separate closures.
--
-- So each of those is now a list. One row per thing, with what it is, where it applies and the
-- reading. The old single boxes stay where they are and their contents are carried across, so
-- nothing already written down is lost.
--
-- Safe to run again.

begin;

create table if not exists dm_day_conditions (
  id          bigint generated always as identity primary key,
  date        date     not null,
  centre_id   smallint not null references centres(id),
  kind        text     not null check (kind in ('Weather', 'Avalanche', 'River', 'Closure')),
  place       text,                      -- "Alpine 1800m+", "Whanganui at Cherry Grove", "Upper Mangatepopo"
  reading     text,                      -- "Heavy rain warning", "Orange", "1.4m and rising", "Closed"
  detail      text,
  sort_order  smallint not null default 0,
  added_by    text,
  created_at  timestamptz not null default now()
);
create index if not exists dm_day_conditions_day on dm_day_conditions (date, centre_id, kind, sort_order);

-- ---------- The elevation bands, so the DM fills in three avalanche ratings, not one
-- These are the bands the NZ Avalanche Advisory reports against. Rename them if Hillary words
-- them differently: the app reads this list rather than having them written into it.
create table if not exists avalanche_bands (
  id         smallint generated always as identity primary key,
  centre_id  smallint references centres(id),
  band       text not null,
  sort_order smallint not null default 0
);
insert into avalanche_bands (centre_id, band, sort_order)
select c.id, b.band, b.n
  from centres c
  cross join (values ('Alpine', 1), ('Sub-alpine', 2), ('Below treeline', 3)) as b(band, n)
 where c.name ilike '%tongariro%'
   and not exists (select 1 from avalanche_bands a where a.centre_id = c.id and a.band = b.band);

-- ---------- Carry across whatever is already written in the single boxes
insert into dm_day_conditions (date, centre_id, kind, place, reading, sort_order, added_by)
select d.date, d.centre_id, 'Weather', null, d.wx_events, 0, d.dm_name
  from dm_day_logs d
 where coalesce(d.wx_events, 'None') not in ('None', '')
   and not exists (select 1 from dm_day_conditions x
                    where x.date = d.date and x.centre_id = d.centre_id and x.kind = 'Weather');

insert into dm_day_conditions (date, centre_id, kind, place, reading, sort_order, added_by)
select d.date, d.centre_id, 'Avalanche', 'All bands', d.avalanche, 0, d.dm_name
  from dm_day_logs d
 where coalesce(d.avalanche, 'Nil') not in ('Nil', '')
   and not exists (select 1 from dm_day_conditions x
                    where x.date = d.date and x.centre_id = d.centre_id and x.kind = 'Avalanche');

insert into dm_day_conditions (date, centre_id, kind, place, reading, sort_order, added_by)
select d.date, d.centre_id, 'River', null, d.river_levels, 0, d.dm_name
  from dm_day_logs d
 where coalesce(d.river_levels, '') <> ''
   and not exists (select 1 from dm_day_conditions x
                    where x.date = d.date and x.centre_id = d.centre_id and x.kind = 'River');

insert into dm_day_conditions (date, centre_id, kind, place, reading, sort_order, added_by)
select d.date, d.centre_id, 'Closure', d.closures, 'Closed', 0, d.dm_name
  from dm_day_logs d
 where coalesce(d.closures, '') <> ''
   and not exists (select 1 from dm_day_conditions x
                    where x.date = d.date and x.centre_id = d.centre_id and x.kind = 'Closure');

-- ---------- Tides, so the coast activities have them on the sheet
alter table dm_day_logs add column if not exists tide_notes text;
alter table dm_day_logs add column if not exists sunset     time;
alter table dm_day_logs add column if not exists forecast   text;

-- ---------- Calling in and out
-- Water trips call on and off the water, mountain trips out of and back in the van, caves in and
-- out of the cave, overnights out of and back into camp — and everything calls back at base.
-- The words live here so the DM screen and the instructor app say the same thing, and so the
-- wording can change without touching the app.
alter table activities drop constraint if exists activities_call_in_type_check;
alter table activities add constraint activities_call_in_type_check
  check (call_in_type in ('None', 'Cave', 'Water', 'Mountain', 'Overnight'));

create table if not exists call_in_kinds (
  kind      text primary key,
  out_words text not null,          -- the call that starts the activity
  in_words  text not null,          -- the call that ends it
  sort_order smallint not null default 0
);
insert into call_in_kinds (kind, out_words, in_words, sort_order) values
  ('Water',     'On the water',     'Off the water',   1),
  ('Mountain',  'Out of the van',   'Back in the van', 2),
  ('Cave',      'Into the cave',    'Out of the cave', 3),
  ('Overnight', 'Into camp',        'Out of camp',     4),
  ('None',      'Away',             'Back',            5)
on conflict (kind) do update set out_words = excluded.out_words, in_words = excluded.in_words;

-- Every trip, whatever it is, finishes with a call from base.
create table if not exists call_in_extra (
  id    smallint generated always as identity primary key,
  words text not null unique
);
insert into call_in_extra (words) values ('Back at base') on conflict (words) do nothing;

-- One row per call actually made, so a trip can call several times in a day.
create table if not exists intention_calls (
  id           bigint generated always as identity primary key,
  intention_id bigint not null references intentions(id) on delete cascade,
  words        text   not null,       -- "On the water", "Back at base"
  at           timestamptz not null default now(),
  taken_by     text,
  note         text
);
create index if not exists intention_calls_int on intention_calls (intention_id, at);

-- ---------- What the day looks like, in one row per centre per day
-- the take sheet is built on the day sheet, so it goes first
drop view if exists v_take_sheet;
drop view if exists v_day_sheet;
create view v_day_sheet with (security_invoker = false) as
select d.date, d.centre_id, c.name as centre, d.dm_name, d.wx_state, d.forecast, d.wx_notes,
       d.tide_notes, d.sunset, d.dm_judgements,
       (select string_agg(coalesce(x.place || ': ', '') || x.reading, ' · ' order by x.sort_order, x.id)
          from dm_day_conditions x where x.date = d.date and x.centre_id = d.centre_id and x.kind = 'Weather')   as weather_events,
       (select string_agg(coalesce(x.place || ': ', '') || x.reading, ' · ' order by x.sort_order, x.id)
          from dm_day_conditions x where x.date = d.date and x.centre_id = d.centre_id and x.kind = 'Avalanche') as avalanche,
       (select string_agg(coalesce(x.place || ': ', '') || x.reading, ' · ' order by x.sort_order, x.id)
          from dm_day_conditions x where x.date = d.date and x.centre_id = d.centre_id and x.kind = 'River')     as river_levels,
       (select string_agg(coalesce(x.place || ': ', '') || x.reading, ' · ' order by x.sort_order, x.id)
          from dm_day_conditions x where x.date = d.date and x.centre_id = d.centre_id and x.kind = 'Closure')   as closures
  from dm_day_logs d
  join centres c on c.id = d.centre_id;

-- ---------- The take sheet: one row per trip, with what is different about today
create view v_take_sheet with (security_invoker = false) as
select i.date, i.centre_id, i.id as intention_id, i.group_name, i.pax, i.plan, i.outcome_of_day,
       i.overnight, i.started_at, i.due_by, i.status,
       (select coalesce(string_agg(p.name, ' + ' order by p.name), '')
          from intention_instructors ii join instructors p on p.id = ii.instructor_id
         where ii.intention_id = i.id)                                   as instructors,
       (select coalesce(string_agg(a.name, ' + ' order by a.name), '')
          from intention_activities ia join activities a on a.id = ia.act_id
         where ia.intention_id = i.id)                                   as activities,
       (select coalesce(string_agg(distinct k.out_words || ' / ' || k.in_words, ' · '), '')
          from intention_activities ia
          join activities a on a.id = ia.act_id
          join call_in_kinds k on k.kind = a.call_in_type
         where ia.intention_id = i.id and a.call_in_type <> 'None')      as calls_required,
       (select coalesce(string_agg(x.words, ' · '), '') from call_in_extra x)  as calls_always,
       (select coalesce(string_agg(to_char(cl.at, 'HH24:MI') || ' ' || cl.words, ' · ' order by cl.at), '')
          from intention_calls cl where cl.intention_id = i.id)          as calls_made,
       -- what to take, straight off the AMPs for the activities on this trip
       (select coalesce(string_agg(distinct m.specific_equipment, ' · '), '')
          from intention_activities ia join amps m on m.act_id = ia.act_id
         where ia.intention_id = i.id and coalesce(m.specific_equipment, '') <> '') as take_with_you,
       (select coalesce(string_agg(distinct m.other_resources, ' · '), '')
          from intention_activities ia join amps m on m.act_id = ia.act_id
         where ia.intention_id = i.id and coalesce(m.other_resources, '') <> '')    as other_resources,
       (select coalesce(string_agg(distinct m.emergency_response, ' · '), '')
          from intention_activities ia join amps m on m.act_id = ia.act_id
         where ia.intention_id = i.id and coalesce(m.emergency_response, '') <> '') as emergency_response,
       s.weather_events, s.avalanche, s.river_levels, s.closures, s.tide_notes, s.sunset, s.forecast
  from intentions i
  left join v_day_sheet s on s.date = i.date and s.centre_id = i.centre_id;

-- ---------- Security
alter table dm_day_conditions enable row level security;
alter table avalanche_bands   enable row level security;
alter table call_in_kinds     enable row level security;
alter table call_in_extra     enable row level security;
alter table intention_calls   enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where tablename = 'dm_day_conditions' and policyname = 'read when logged in') then
    create policy "read when logged in" on dm_day_conditions for select to authenticated using (true);
    create policy "manager can change"  on dm_day_conditions for all    to authenticated using (is_manager()) with check (is_manager());
  end if;
  if not exists (select 1 from pg_policies where tablename = 'avalanche_bands' and policyname = 'read when logged in') then
    create policy "read when logged in" on avalanche_bands for select to authenticated using (true);
    create policy "manager can change"  on avalanche_bands for all    to authenticated using (is_manager()) with check (is_manager());
  end if;
  if not exists (select 1 from pg_policies where tablename = 'call_in_kinds' and policyname = 'read when logged in') then
    create policy "read when logged in" on call_in_kinds for select to authenticated using (true);
    create policy "manager can change"  on call_in_kinds for all    to authenticated using (is_manager()) with check (is_manager());
  end if;
  if not exists (select 1 from pg_policies where tablename = 'call_in_extra' and policyname = 'read when logged in') then
    create policy "read when logged in" on call_in_extra for select to authenticated using (true);
    create policy "manager can change"  on call_in_extra for all    to authenticated using (is_manager()) with check (is_manager());
  end if;
  -- An instructor can record their own call; the DM records anyone's.
  if not exists (select 1 from pg_policies where tablename = 'intention_calls' and policyname = 'read when logged in') then
    create policy "read when logged in" on intention_calls for select to authenticated using (true);
    create policy "on my own trip" on intention_calls for insert to authenticated
      with check (is_manager() or exists (select 1 from intention_instructors ii
                                           where ii.intention_id = intention_id and ii.instructor_id = my_instructor_id()));
    create policy "manager can change" on intention_calls for update to authenticated using (is_manager()) with check (is_manager());
    create policy "manager can remove"  on intention_calls for delete to authenticated using (is_manager());
  end if;
end $$;

grant select, insert, update, delete on dm_day_conditions, avalanche_bands, call_in_kinds, call_in_extra, intention_calls to authenticated;
grant usage, select on all sequences in schema public to authenticated;
grant select on v_day_sheet, v_take_sheet to authenticated;
revoke all on v_day_sheet, v_take_sheet from anon;

commit;

select kind, count(*) as rows_carried_across from dm_day_conditions group by 1 order by 1;
select (select count(*) from avalanche_bands) as avalanche_bands,
       (select count(*) from call_in_kinds)   as call_in_kinds;

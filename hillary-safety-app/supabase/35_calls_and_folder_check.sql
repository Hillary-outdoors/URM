-- URMA · step 35 · The two steps that did not take: calls, and the folder check
--
-- This is 33 and 34 in one paste, unchanged apart from two things at the top:
--   · the search path is pinned, so nothing depends on how your session happens to be set up
--   · it checks what it needs first and says plainly what is missing, instead of failing
--     halfway through with an error about a table that is plainly there
--
--   A. call_options, log_call and undo_call — the DM picks the call from a list
--   B. 'folder' as a source for a tick, so folder-check mode can save without a typed reason
--
-- Paste the WHOLE file and press Run. If any of it is selected when you press Run, Supabase runs
-- only the selection — which is one way to get an error about a table that exists.
--
-- Safe to run again, and safe if part of 33 or 34 did get through earlier.

set search_path = public, extensions;

do $$
declare missing text := '';
begin
  if to_regclass('public.comp_signoffs')   is null then missing := missing || 'table comp_signoffs, '; end if;
  if to_regclass('public.intentions')      is null then missing := missing || 'table intentions, '; end if;
  if to_regclass('public.intention_calls') is null then missing := missing || 'table intention_calls (step 30), '; end if;
  if to_regclass('public.v_day_sheet')     is null then missing := missing || 'view v_day_sheet (step 30), '; end if;
  if not exists (select 1 from pg_proc where proname = 'is_on_intention') then missing := missing || 'function is_on_intention, '; end if;
  if not exists (select 1 from pg_proc where proname = 'is_manager')      then missing := missing || 'function is_manager, '; end if;
  if missing <> '' then
    raise exception 'Cannot run this yet. Missing: %. Check you are on the right project.', rtrim(missing, ', ');
  end if;
  raise notice 'Preflight fine.';
end $$;


-- ---------------------------------------------------------------------
--  PART A · Calls
-- ---------------------------------------------------------------------

begin;

-- ---------- The list the DM sees
create table if not exists call_options (
  id          smallint generated always as identity primary key,
  words       text not null unique,
  closes_trip boolean not null default false,   -- this one means they are back and the trip is done
  sort_order  smallint not null default 0
);

insert into call_options (words, closes_trip, sort_order) values
  ('On the water',       false, 10),
  ('Off the water',      false, 20),
  ('Into the cave',      false, 30),
  ('Out of the cave',    false, 40),
  ('Out of the van',     false, 50),
  ('Back in the van',    false, 60),
  ('Into camp',          false, 70),
  ('Out of camp',        false, 80),
  ('Overnight check in', false, 90),
  ('Changed plan',       false, 100),
  ('Running late',       false, 110),
  ('All well',           false, 120),
  ('Back at base',       true,  200)
on conflict (words) do update set closes_trip = excluded.closes_trip, sort_order = excluded.sort_order;

-- ---------- Taking a call
-- Logs it against the intention. If it is the call that means they are back, it closes the trip
-- the same way the old button did.
create or replace function log_call(p_intention bigint, p_words text,
                                    p_note text default null, p_closes boolean default null)
returns bigint language plpgsql security definer set search_path = public as $$
declare v_id bigint; v_closes boolean; v_who text;
begin
  if not (is_manager() or is_on_intention(p_intention)) then
    raise exception 'You are not on this intention';
  end if;
  if coalesce(trim(p_words), '') = '' then
    raise exception 'Say what the call was';
  end if;

  -- If the caller did not say, look the wording up; anything unrecognised does not close a trip.
  v_closes := coalesce(p_closes, (select closes_trip from call_options where words = p_words), false);
  select name into v_who from instructors where id = my_instructor_id();

  insert into intention_calls (intention_id, words, taken_by, note)
  values (p_intention, trim(p_words), v_who, nullif(trim(p_note), ''))
  returning id into v_id;

  update intentions
     set called_in_at  = (now() at time zone 'Pacific/Auckland')::time(0),
         called_in_as  = trim(p_words),
         debrief_notes = case when v_closes then coalesce(nullif(trim(p_note), ''), debrief_notes) else debrief_notes end,
         status        = case when v_closes then 'Closed' else status end
   where id = p_intention and status <> 'Closed';

  return v_id;
end $$;

create or replace function undo_call(p_call bigint) returns void
language plpgsql security definer set search_path = public as $$
declare v_int bigint;
begin
  select intention_id into v_int from intention_calls where id = p_call;
  if v_int is null then return; end if;
  if not (is_manager() or is_on_intention(v_int)) then
    raise exception 'You are not on this intention';
  end if;
  delete from intention_calls where id = p_call;

  -- If that was the call that ended the trip, the trip is open again.
  update intentions i set status = 'Approved'
   where i.id = v_int and i.status = 'Closed'
     and not exists (select 1 from intention_calls c
                      join call_options o on o.words = c.words and o.closes_trip
                     where c.intention_id = v_int);

  -- put the intention back to the call before this one, if there was one
  update intentions i
     set called_in_at = c.at::time(0), called_in_as = c.words
    from (select at, words from intention_calls where intention_id = v_int order by at desc limit 1) c
   where i.id = v_int;
  update intentions set called_in_at = null, called_in_as = null
   where id = v_int and not exists (select 1 from intention_calls where intention_id = v_int);
end $$;

revoke all on function log_call(bigint, text, text, boolean) from public, anon;
revoke all on function undo_call(bigint) from public, anon;
grant execute on function log_call(bigint, text, text, boolean) to authenticated;
grant execute on function undo_call(bigint) to authenticated;

alter table call_options enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where tablename = 'call_options' and policyname = 'read when logged in') then
    create policy "read when logged in" on call_options for select to authenticated using (true);
    create policy "manager can change"  on call_options for all    to authenticated using (is_manager()) with check (is_manager());
  end if;
end $$;
grant select, insert, update, delete on call_options to authenticated;

-- ---------- Every trip's calls, for the day sheet and the take sheet
drop view if exists v_take_sheet;
create view v_take_sheet with (security_invoker = false) as
select i.date, i.centre_id, i.id as intention_id, i.group_name, i.pax, i.plan, i.outcome_of_day,
       i.overnight, i.started_at, i.due_by, i.status,
       (select coalesce(string_agg(p.name, ' + ' order by p.name), '')
          from intention_instructors ii join instructors p on p.id = ii.instructor_id
         where ii.intention_id = i.id)                                   as instructors,
       (select coalesce(string_agg(a.name, ' + ' order by a.name), '')
          from intention_activities ia join activities a on a.id = ia.act_id
         where ia.intention_id = i.id)                                   as activities,
       (select coalesce(string_agg(to_char(cl.at at time zone 'Pacific/Auckland', 'HH24:MI') || ' ' || cl.words,
                                   ' · ' order by cl.at), '')
          from intention_calls cl where cl.intention_id = i.id)          as calls_made,
       (select to_char(max(cl.at) at time zone 'Pacific/Auckland', 'HH24:MI')
          from intention_calls cl where cl.intention_id = i.id)          as last_heard,
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

grant select on v_take_sheet to authenticated;
revoke all on v_take_sheet from anon;

commit;


-- ---------------------------------------------------------------------
--  PART B · Copying the paper folders in
-- ---------------------------------------------------------------------

begin;

alter table comp_signoffs drop constraint if exists comp_signoffs_source_check;
alter table comp_signoffs add  constraint comp_signoffs_source_check
  check (source in ('self', 'manual', 'training_log', 'override', 'scan', 'backfill', 'folder'));

-- The old rule: anything that is not a Self tick must name a signer and give a reason, unless it
-- came from a training log. A folder tick joins training logs in that exemption.
alter table comp_signoffs drop constraint if exists comp_signoffs_check;
alter table comp_signoffs add  constraint comp_signoffs_check
  check (tick_type = 'self'
         or (signed_by is not null and (source in ('training_log', 'folder', 'scan', 'backfill')
                                        or reason is not null)));

create index if not exists comp_signoffs_folder on comp_signoffs (source) where source = 'folder';

commit;


-- ---------------------------------------------------------------------
--  CHECKS · all three should say true, and the list should have 13 rows
-- ---------------------------------------------------------------------

select exists (select 1 from pg_proc where proname = 'log_call')  as log_call_exists,
       exists (select 1 from pg_proc where proname = 'undo_call') as undo_call_exists,
       (select pg_get_constraintdef(oid) like '%folder%' from pg_constraint
         where conrelid = 'public.comp_signoffs'::regclass and conname like '%source%' limit 1)
         as folder_is_an_allowed_source;

select words, closes_trip from call_options order by sort_order;

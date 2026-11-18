-- URMA · step 33 · Calls, picked at the time rather than set per activity
--
-- Assigning a call type to each of the 80 activities turned out to be the wrong shape. The DM
-- knows what call they are taking when the radio goes; what they need is the list in front of them.
-- So every option is offered on every intention, and whoever takes the call picks one — or types
-- something that is not on the list, like "checked in for overnight at 6pm".
--
-- The wrong one will get picked occasionally. That is fine: a call can be corrected, and a call
-- logged against the wrong wording is still a record that the trip was heard from.
--
-- One consequence worth stating: the overdue watch used to fire only for trips whose activity had
-- a call type. With call types no longer maintained, that would have gone quiet for most trips.
-- Now every intention with a time to be back by is watched. It errs towards telling you.
--
-- Safe to run again.

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

select words, closes_trip from call_options order by sort_order;

-- =====================================================================
-- FILE 3 of 4: WORKED-OUT VALUES AND ACTIONS
-- Run after file 2.
--   Views     = things the system works out live and never stores.
--   Functions = the few actions an instructor is allowed to take.
-- =====================================================================

-- Has each person signed the CURRENT version of each AMP?
create or replace view v_amp_status with (security_invoker = true) as
select a.id as amp_id, a.act_id, a.title, a.version,
       i.id as instructor_id, i.name as instructor_name, i.centre_id,
       k.signed_version,
       (a.version > 0 and k.signed_version is not distinct from a.version) as up_to_date
from amps a
cross join instructors i
left join lateral (select max(amp_version) as signed_version
                   from amp_acknowledgements
                   where amp_id = a.id and instructor_id = i.id) k on true
where i.account_type = 'instructor' and i.employment <> 'Past staff';

-- Where is each person on each competency? Worked out from the ticks.
--   Not started : no ticks yet
--   Direct      : some ticks
--   Indirect    : every required Self and Obs 1 tick is done
--   Competent   : every required tick is done
create or replace view v_competency_status with (security_invoker = true) as
with required as (
  select l.comp_id, l.id as line_id, l.auto_from_amp, t.tick_type
  from competency_lines l
  cross join lateral (values ('self', l.needs_self), ('obs1', l.needs_obs1),
                             ('assess1', l.needs_assess1), ('assess2', l.needs_assess2)) as t(tick_type, needed)
  where t.needed
),
ticks as (
  select i.id as instructor_id, r.comp_id, r.auto_from_amp, r.tick_type,
         case when r.auto_from_amp then
                exists (select 1 from amp_acknowledgements k
                        join amps a on a.id = k.amp_id
                        join competencies c on c.id = r.comp_id
                        where k.instructor_id = i.id and a.act_id = c.act_id)
              else
                exists (select 1 from comp_signoffs s
                        where s.instructor_id = i.id and s.line_id = r.line_id and s.tick_type = r.tick_type)
         end as done
  from instructors i cross join required r
),
totals as (
  select instructor_id, comp_id,
         count(*)                                                        as total,
         count(*) filter (where done)                                    as done,
         count(*) filter (where done and not auto_from_amp)              as real_done,
         count(*) filter (where not auto_from_amp and tick_type in ('self','obs1'))          as so_total,
         count(*) filter (where done and not auto_from_amp and tick_type in ('self','obs1')) as so_done
  from ticks group by instructor_id, comp_id
)
select c.id as comp_id, c.name, c.level, c.act_id, c.centre_id,
       i.id as instructor_id, i.name as instructor_name,
       coalesce(t.total, 0) as total, coalesce(t.done, 0) as done,
       case when coalesce(t.total, 0) = 0 then 'Not started'
            when t.done = t.total       then 'Competent'
            when t.real_done = 0        then 'Not started'
            when t.so_done = t.so_total then 'Indirect'
            else 'Direct' end as status
from competencies c
cross join instructors i
left join totals t on t.comp_id = c.id and t.instructor_id = i.id
where i.account_type = 'instructor' and i.employment <> 'Past staff';

-- ---------- Actions an instructor can take ----------

-- Sign the current version of an AMP.
create or replace function acknowledge_amp(p_amp bigint) returns void
language plpgsql security definer set search_path = public as $$
declare me uuid := my_instructor_id(); v integer;
begin
  if me is null then raise exception 'Not logged in as an instructor'; end if;
  select version into v from amps where id = p_amp;
  if v is null or v = 0 then raise exception 'This AMP is not published yet'; end if;
  insert into amp_acknowledgements (instructor_id, amp_id, amp_version)
  values (me, p_amp, v) on conflict do nothing;
end $$;

-- Send an intention to the Duty Manager.
create or replace function submit_intention(
  p_centre smallint, p_date date, p_acts bigint[], p_with uuid[],
  p_overnight boolean, p_due time, p_pax integer, p_outcome text, p_plan text
) returns bigint
language plpgsql security definer set search_path = public as $$
declare me uuid := my_instructor_id(); new_id bigint;
begin
  if me is null then raise exception 'Not logged in as an instructor'; end if;
  if p_acts is null or cardinality(p_acts) = 0 then raise exception 'Pick at least one activity'; end if;
  insert into intentions (centre_id, date, overnight, due_by, pax, outcome_of_day, plan, submitted_by)
  values (p_centre, p_date, coalesce(p_overnight, false), p_due, p_pax, p_outcome, p_plan, me)
  returning id into new_id;
  insert into intention_instructors (intention_id, instructor_id)
  select new_id, x from (select me as x union select unnest(coalesce(p_with, '{}'))) s
  where x in (select id from instructors);
  insert into intention_activities (intention_id, act_id)
  select new_id, a from (select distinct unnest(p_acts) as a) s
  where a in (select id from activities);
  return new_id;
end $$;

-- Call in safe: this is what ends an intention.
create or replace function call_in_safe(p_intention bigint, p_as text, p_notes text default null) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not (is_manager() or is_on_intention(p_intention)) then
    raise exception 'You are not on this intention';
  end if;
  update intentions
     set called_in_at  = (now() at time zone 'Pacific/Auckland')::time(0),
         called_in_as  = p_as,
         debrief_notes = coalesce(nullif(p_notes, ''), debrief_notes),
         status        = 'Closed'
   where id = p_intention and status <> 'Closed';
end $$;

-- Only logged-in people may run these.
revoke all on function my_instructor_id()        from public, anon;
revoke all on function is_manager()              from public, anon;
revoke all on function is_on_intention(bigint)   from public, anon;
revoke all on function acknowledge_amp(bigint)   from public, anon;
revoke all on function call_in_safe(bigint, text, text) from public, anon;
revoke all on function submit_intention(smallint, date, bigint[], uuid[], boolean, time, integer, text, text) from public, anon;
grant execute on function my_instructor_id()        to authenticated;
grant execute on function is_manager()              to authenticated;
grant execute on function is_on_intention(bigint)   to authenticated;
grant execute on function acknowledge_amp(bigint)   to authenticated;
grant execute on function call_in_safe(bigint, text, text) to authenticated;
grant execute on function submit_intention(smallint, date, bigint[], uuid[], boolean, time, integer, text, text) to authenticated;
grant select on v_amp_status, v_competency_status to authenticated;
revoke all on v_amp_status, v_competency_status from anon;

-- URMA · step 28 · Store the status instead of working it out every time
--
-- Until now every read worked the answer out from scratch: count the boxes each form asks for,
-- count the ones this person has, decide. Correct, but it is arithmetic over 192,000 rows and it
-- happened again on every search.
--
-- Now there is a table, comp_status, holding one row per person per competency, and the ticks keep
-- it up to date themselves. Adding, changing or removing a tick updates the rows it affects, in the
-- same breath as the tick. Nothing writes to comp_status by hand: there is no screen for it, the app
-- cannot reach it, and the only things that touch it are the triggers below.
--
-- Two places for one truth is a real risk, so:
--   · comp_status_drift() compares every stored row against the arithmetic and lists any that
--     disagree. On a healthy database it returns nothing. Run it whenever you want reassurance.
--   · rebuild_comp_status() throws the table away and works all of it out again from the ticks.
--     The ticks are the truth; this table is only ever a summary of them.
--
-- v_competency_status keeps its name and its columns, so nothing in the app changes.
--
-- Safe to run again.

begin;

create table if not exists comp_status (
  instructor_id uuid    not null references instructors(id) on delete cascade,
  comp_id       bigint  not null references competencies(id) on delete cascade,
  total         integer not null default 0,
  done          integer not null default 0,
  status        text    not null default 'Not started',
  updated_at    timestamptz not null default now(),
  primary key (instructor_id, comp_id)
);
create index if not exists comp_status_comp_idx on comp_status (comp_id);

-- ---------- The arithmetic, in one place
-- Exactly the sums the old view did. Call it with nothing to redo everything, or with a short list
-- of people and competencies to redo just those.
create or replace function refresh_comp_status(p_instructors uuid[] default null,
                                               p_comps bigint[] default null)
returns integer language plpgsql security definer set search_path = public as $$
declare v_n integer;
begin
  with people as (
    select i.id from instructors i
     where i.account_type = 'instructor' and i.employment <> 'Past staff'
       and (p_instructors is null or i.id = any(p_instructors))
  ),
  comps as (
    select c.id from competencies c where p_comps is null or c.id = any(p_comps)
  ),
  req as (                                   -- every box the forms actually ask for
    select l.comp_id, l.id as line_id, l.auto_from_amp, t.tick_type
      from competency_lines l
      join comps on comps.id = l.comp_id
      cross join lateral (values ('self', l.needs_self), ('obs1', l.needs_obs1), ('obs2', l.needs_obs2),
                                 ('assess1', l.needs_assess1), ('assess2', l.needs_assess2),
                                 ('assess3', l.needs_assess3)) as t(tick_type, needed)
     where t.needed
  ),
  tot as (
    select comp_id,
           count(*)                                                                          as total,
           count(*) filter (where auto_from_amp)                                             as amp_total,
           count(*) filter (where not auto_from_amp and tick_type in ('self','obs1','obs2')) as so_total
      from req group by comp_id
  ),
  got as (
    select s.instructor_id, r.comp_id,
           count(*)                                                      as done,
           count(*) filter (where r.tick_type in ('self','obs1','obs2')) as so_done
      from comp_signoffs s
      join req r on r.line_id = s.line_id and r.tick_type = s.tick_type and not r.auto_from_amp
      join people p on p.id = s.instructor_id
     group by 1, 2
  ),
  ampgot as (                                -- lines that tick themselves when the AMP is signed
    select k.instructor_id, c.id as comp_id, t.amp_total as done
      from amp_acknowledgements k
      join people p on p.id = k.instructor_id
      join amps a on a.id = k.amp_id and k.amp_version = a.version and a.version > 0
      join competencies c on c.act_id = a.act_id
      join tot t on t.comp_id = c.id
     where t.amp_total > 0
  ),
  fresh as (
    select p.id as instructor_id, c.id as comp_id,
           coalesce(t.total, 0)                       as total,
           coalesce(g.done, 0) + coalesce(ag.done, 0) as done,
           case when coalesce(t.total, 0) = 0                            then 'Not started'
                when coalesce(g.done,0) + coalesce(ag.done,0) >= t.total then 'Competent'
                when coalesce(g.done, 0) = 0                             then 'Not started'
                when t.so_total > 0 and g.so_done >= t.so_total          then 'Indirect'
                else 'Direct' end                     as status
      from people p
      cross join comps c
      left join tot    t  on t.comp_id = c.id
      left join got    g  on g.comp_id = c.id and g.instructor_id = p.id
      left join ampgot ag on ag.comp_id = c.id and ag.instructor_id = p.id
  )
  insert into comp_status (instructor_id, comp_id, total, done, status, updated_at)
  select instructor_id, comp_id, total, done, status, now() from fresh
  on conflict (instructor_id, comp_id) do update
     set total = excluded.total, done = excluded.done, status = excluded.status, updated_at = now()
   where comp_status.total <> excluded.total or comp_status.done <> excluded.done
      or comp_status.status <> excluded.status;

  get diagnostics v_n = row_count;

  -- people who have left or competencies that have gone keep no row
  delete from comp_status cs
   where not exists (select 1 from instructors i
                      where i.id = cs.instructor_id and i.account_type = 'instructor'
                        and i.employment <> 'Past staff')
      or not exists (select 1 from competencies c where c.id = cs.comp_id);

  return v_n;
end $$;

create or replace function rebuild_comp_status() returns integer
language plpgsql security definer set search_path = public as $$
begin
  delete from comp_status;
  return refresh_comp_status();
end $$;

-- ---------- The ticks keep it up to date
-- Statement-level triggers with transition tables, so ticking 130 boxes in one go recalculates the
-- one competency once, not 130 times.
create or replace function comp_status_from_signoffs() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_people uuid[]; v_comps bigint[];
begin
  create temp table if not exists _touched (instructor_id uuid, comp_id bigint) on commit drop;
  delete from _touched;

  if tg_op in ('INSERT', 'UPDATE') then
    insert into _touched select distinct n.instructor_id, l.comp_id
      from new_rows n join competency_lines l on l.id = n.line_id;
  end if;
  if tg_op in ('DELETE', 'UPDATE') then
    insert into _touched select distinct o.instructor_id, l.comp_id
      from old_rows o join competency_lines l on l.id = o.line_id;
  end if;

  select array_agg(distinct instructor_id), array_agg(distinct comp_id) into v_people, v_comps from _touched;
  if v_people is not null then perform refresh_comp_status(v_people, v_comps); end if;
  return null;
end $$;

drop trigger if exists comp_status_ins on comp_signoffs;
drop trigger if exists comp_status_upd on comp_signoffs;
drop trigger if exists comp_status_del on comp_signoffs;
create trigger comp_status_ins after insert on comp_signoffs
  referencing new table as new_rows for each statement execute function comp_status_from_signoffs();
create trigger comp_status_upd after update on comp_signoffs
  referencing new table as new_rows old table as old_rows for each statement execute function comp_status_from_signoffs();
create trigger comp_status_del after delete on comp_signoffs
  referencing old table as old_rows for each statement execute function comp_status_from_signoffs();

-- Changing what a form asks for changes where everyone stands on it.
create or replace function comp_status_from_lines() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_comps bigint[];
begin
  if tg_op = 'DELETE' then
    select array_agg(distinct comp_id) into v_comps from old_rows;
  elsif tg_op = 'INSERT' then
    select array_agg(distinct comp_id) into v_comps from new_rows;
  else
    select array_agg(distinct comp_id) into v_comps from
      (select comp_id from new_rows union select comp_id from old_rows) z;
  end if;
  if v_comps is not null then perform refresh_comp_status(null, v_comps); end if;
  return null;
end $$;

drop trigger if exists comp_status_lines_ins on competency_lines;
drop trigger if exists comp_status_lines_upd on competency_lines;
drop trigger if exists comp_status_lines_del on competency_lines;
create trigger comp_status_lines_ins after insert on competency_lines
  referencing new table as new_rows for each statement execute function comp_status_from_lines();
create trigger comp_status_lines_upd after update on competency_lines
  referencing new table as new_rows old table as old_rows for each statement execute function comp_status_from_lines();
create trigger comp_status_lines_del after delete on competency_lines
  referencing old table as old_rows for each statement execute function comp_status_from_lines();

-- Signing an AMP ticks the lines that come with it.
create or replace function comp_status_from_amps() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_people uuid[];
begin
  if tg_op = 'DELETE' then select array_agg(distinct instructor_id) into v_people from old_rows;
  elsif tg_op = 'INSERT' then select array_agg(distinct instructor_id) into v_people from new_rows;
  else select array_agg(distinct instructor_id) into v_people from
    (select instructor_id from new_rows union select instructor_id from old_rows) z;
  end if;
  if v_people is not null then perform refresh_comp_status(v_people, null); end if;
  return null;
end $$;

drop trigger if exists comp_status_amp_ins on amp_acknowledgements;
drop trigger if exists comp_status_amp_upd on amp_acknowledgements;
drop trigger if exists comp_status_amp_del on amp_acknowledgements;
create trigger comp_status_amp_ins after insert on amp_acknowledgements
  referencing new table as new_rows for each statement execute function comp_status_from_amps();
create trigger comp_status_amp_upd after update on amp_acknowledgements
  referencing new table as new_rows old table as old_rows for each statement execute function comp_status_from_amps();
create trigger comp_status_amp_del after delete on amp_acknowledgements
  referencing old table as old_rows for each statement execute function comp_status_from_amps();

-- A new person, a new competency, or someone marked as past staff.
create or replace function comp_status_from_people() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  perform refresh_comp_status();
  return null;
end $$;

drop trigger if exists comp_status_people on instructors;
create trigger comp_status_people after insert or delete or update of employment, account_type, centre_id
  on instructors for each statement execute function comp_status_from_people();

drop trigger if exists comp_status_comps on competencies;
create trigger comp_status_comps after insert or delete on competencies
  for each statement execute function comp_status_from_people();

-- ---------- The view everything already reads, now just a lookup
drop view if exists v_activity_ready;
drop view if exists v_intention_ready;
drop view if exists v_log_review;
drop view if exists v_competency_status;

create view v_competency_status with (security_invoker = true) as
select c.id as comp_id, c.name, c.level, c.act_id, c.centre_id, c.box_labels, c.code,
       i.id as instructor_id, i.name as instructor_name,
       s.total, s.done, s.status
  from comp_status s
  join competencies c on c.id = s.comp_id
  join instructors  i on i.id = s.instructor_id;

-- rebuilt unchanged, on top of the new view
create view v_activity_ready with (security_invoker = true) as
with chk as (
  select i.id as instructor_id, r.act_id, r.kind, r.item_name,
         case when r.kind = 'Competency'
              then exists (select 1 from v_competency_status s
                           where s.instructor_id = i.id and s.comp_id = r.item_id and s.status = 'Competent')
              else exists (select 1 from v_amp_status s
                           where s.instructor_id = i.id and s.amp_id = r.item_id and s.up_to_date)
         end as ok
  from instructors i join v_activity_requirements r on true
  where i.account_type = 'instructor' and i.employment <> 'Past staff'
)
select instructor_id, act_id, bool_and(ok) as ready,
       count(*) filter (where not ok) as missing_count,
       string_agg(case when not ok then kind || ': ' || item_name end, ' · ' order by kind, item_name) as missing
from chk group by instructor_id, act_id;

create view v_intention_ready with (security_invoker = true) as
with chk as (
  select ii.intention_id, ii.instructor_id, r.kind, r.item_name,
         case when r.kind = 'Competency'
              then exists (select 1 from v_competency_status s
                           where s.instructor_id = ii.instructor_id and s.comp_id = r.item_id and s.status = 'Competent')
              else exists (select 1 from v_amp_status s
                           where s.instructor_id = ii.instructor_id and s.amp_id = r.item_id and s.up_to_date)
         end as ok
  from intention_instructors ii
  join v_intention_requirements r on r.intention_id = ii.intention_id
)
select intention_id, instructor_id, bool_and(ok) as ready,
       count(*) filter (where not ok) as missing_count,
       string_agg(case when not ok then kind || ': ' || item_name end, ' · ' order by kind, item_name) as missing
from chk group by intention_id, instructor_id;

create view v_log_review with (security_invoker = true) as
select l.id as log_id, l.date, l.instructor_id, i.name as instructor, l.trainer, l.activity_text,
       l.location, l.outcome, l.summary, l.next_steps, l.applied_at, l.ticks_made,
       c.id as comp_id, c.name as comp_name, c.level, s.status as status_now
  from training_logs l
  join instructors i on i.id = l.instructor_id
  left join training_log_comps m on m.log_id = l.id
  left join competencies c on c.id = m.comp_id
  left join v_competency_status s on s.instructor_id = l.instructor_id and s.comp_id = c.id;

-- ---------- The honesty check
-- Works the answer out the long way and compares. Nothing listed means the table is right.
create or replace function comp_status_drift()
returns table (instructor text, competency text, stored text, should_be text)
language sql security definer set search_path = public as $$
  with req as (
    select l.comp_id, l.id as line_id, l.auto_from_amp, t.tick_type
      from competency_lines l
      cross join lateral (values ('self', l.needs_self), ('obs1', l.needs_obs1), ('obs2', l.needs_obs2),
                                 ('assess1', l.needs_assess1), ('assess2', l.needs_assess2),
                                 ('assess3', l.needs_assess3)) as t(tick_type, needed)
     where t.needed
  ),
  tot as (
    select comp_id, count(*) as total,
           count(*) filter (where auto_from_amp) as amp_total,
           count(*) filter (where not auto_from_amp and tick_type in ('self','obs1','obs2')) as so_total
      from req group by comp_id
  ),
  got as (
    select s.instructor_id, r.comp_id, count(*) as done,
           count(*) filter (where r.tick_type in ('self','obs1','obs2')) as so_done
      from comp_signoffs s
      join req r on r.line_id = s.line_id and r.tick_type = s.tick_type and not r.auto_from_amp
     group by 1, 2
  ),
  ampgot as (
    select k.instructor_id, c.id as comp_id, t.amp_total as done
      from amp_acknowledgements k
      join amps a on a.id = k.amp_id and k.amp_version = a.version and a.version > 0
      join competencies c on c.act_id = a.act_id
      join tot t on t.comp_id = c.id
     where t.amp_total > 0
  ),
  live as (
    select i.id as instructor_id, c.id as comp_id,
           case when coalesce(t.total, 0) = 0                            then 'Not started'
                when coalesce(g.done,0) + coalesce(ag.done,0) >= t.total then 'Competent'
                when coalesce(g.done, 0) = 0                             then 'Not started'
                when t.so_total > 0 and g.so_done >= t.so_total          then 'Indirect'
                else 'Direct' end as status
      from competencies c
      cross join instructors i
      left join tot    t  on t.comp_id = c.id
      left join got    g  on g.comp_id = c.id and g.instructor_id = i.id
      left join ampgot ag on ag.comp_id = c.id and ag.instructor_id = i.id
     where i.account_type = 'instructor' and i.employment <> 'Past staff'
  )
  select i.name, c.name || ' L' || c.level, coalesce(s.status, '(no row)'), live.status
    from live
    join instructors  i on i.id = live.instructor_id
    join competencies c on c.id = live.comp_id
    left join comp_status s on s.instructor_id = live.instructor_id and s.comp_id = live.comp_id
   where coalesce(s.status, '(no row)') <> live.status
   order by 1, 2;
$$;

-- ---------- Security: read-only to everyone, written only by the triggers
alter table comp_status enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where tablename = 'comp_status' and policyname = 'read own or manager') then
    create policy "read own or manager" on comp_status for select to authenticated
      using (is_manager() or instructor_id = my_instructor_id());
  end if;
end $$;
-- deliberately no insert, update or delete policy: nobody edits this table through the app

-- Supabase grants broadly on new tables by default, so take the write rights away explicitly.
revoke insert, update, delete, truncate on comp_status from authenticated, anon;
grant select on comp_status, v_competency_status, v_activity_ready, v_intention_ready, v_log_review to authenticated;
revoke all on comp_status, v_competency_status, v_activity_ready, v_intention_ready, v_log_review from anon;
revoke all on function refresh_comp_status(uuid[], bigint[]) from public;
grant execute on function rebuild_comp_status() to authenticated;
grant execute on function comp_status_drift() to authenticated;

commit;

-- Fill it in from the ticks that are already there.
select rebuild_comp_status() as rows_written;

-- Should list nothing at all.
select * from comp_status_drift();

-- Where everyone stands, read straight from the table now.
select status, count(*) as competencies from comp_status group by 1 order by 2 desc;

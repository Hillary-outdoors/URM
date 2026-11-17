-- URMA · step 22 · Checking an intention that does not fit a preset
--
-- Most days are an activity off the list, and the app can work out what is needed from that alone.
-- Some are not: a one-off trip, an unusual combination, a new place. For those the DM says which
-- competencies and which AMPs this particular intention needs, and the app checks against that.
--
-- Safe to run again.

-- 1. What the DM has pinned to one intention, on top of whatever its activities already ask for.
create table if not exists intention_comps (
  intention_id bigint not null references intentions(id) on delete cascade,
  comp_id      bigint not null references competencies(id) on delete cascade,
  role         text   not null default 'Instructor' check (role in ('Instructor','Trip leader','Assistant')),
  added_by     text,
  primary key (intention_id, comp_id, role)
);
create table if not exists intention_amps (
  intention_id bigint not null references intentions(id) on delete cascade,
  amp_id       bigint not null references amps(id) on delete cascade,
  added_by     text,
  primary key (intention_id, amp_id)
);

-- 2. Everything this intention asks for: from its activities, plus whatever the DM pinned on.
create or replace view v_intention_requirements with (security_invoker = true) as
  select x.intention_id, r.kind, r.item_id, r.item_name, r.role,
         case when r.everyone then 'Needed by everyone' else 'From the activity' end as came_from
    from intention_activities x
    join v_activity_requirements r on r.act_id = x.act_id
  union
  select c.intention_id, 'Competency', k.id, k.name || ' (L' || k.level || ')', c.role, 'Added by the DM'
    from intention_comps c join competencies k on k.id = c.comp_id
  union
  select a.intention_id, 'AMP', m.id, m.title, 'Instructor', 'Added by the DM'
    from intention_amps a join amps m on m.id = a.amp_id;

-- 3. Is each instructor on the intention ready for it, and what are they short of?
create or replace view v_intention_ready with (security_invoker = true) as
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
select intention_id, instructor_id,
       bool_and(ok) as ready,
       count(*) filter (where not ok) as missing_count,
       string_agg(case when not ok then kind || ': ' || item_name end, ' · ' order by kind, item_name) as missing
from chk group by intention_id, instructor_id;

alter table intention_comps enable row level security;
alter table intention_amps  enable row level security;
drop policy if exists int_comps_read on intention_comps;
drop policy if exists int_comps_write on intention_comps;
drop policy if exists int_amps_read on intention_amps;
drop policy if exists int_amps_write on intention_amps;
create policy int_comps_read  on intention_comps for select to authenticated using (true);
create policy int_comps_write on intention_comps for all    to authenticated using (is_manager()) with check (is_manager());
create policy int_amps_read   on intention_amps  for select to authenticated using (true);
create policy int_amps_write  on intention_amps  for all    to authenticated using (is_manager()) with check (is_manager());
grant select on v_intention_requirements, v_intention_ready to authenticated;
revoke all on v_intention_requirements, v_intention_ready from anon;

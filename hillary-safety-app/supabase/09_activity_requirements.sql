-- URMA · step 9 · What each activity needs
--
-- An activity is the thing a DM writes on the day sheet: "Bush bashing", "Canoe Lake Otamangakau",
-- "High Ropes". To run it an instructor may need several AMPs signed and several competencies held,
-- and a few of each are needed by everyone whatever they are running.
-- This step adds those links so "Who can run what" can answer the question from the activity alone.

-- 1. Competencies an activity needs. role: who needs it on the day.
create table if not exists activity_comps (
  act_id   bigint not null references activities(id) on delete cascade,
  comp_id  bigint not null references competencies(id) on delete cascade,
  role     text   not null default 'Instructor' check (role in ('Instructor','Trip leader','Assistant')),
  note     text,
  primary key (act_id, comp_id, role)
);

-- 2. AMPs an activity needs beyond its own.
create table if not exists activity_amps (
  act_id  bigint not null references activities(id) on delete cascade,
  amp_id  bigint not null references amps(id) on delete cascade,
  note    text,
  primary key (act_id, amp_id)
);

-- 3. The ones everyone needs, whatever they are running.
alter table competencies add column if not exists required_for_all boolean not null default false;
alter table amps         add column if not exists required_for_all boolean not null default false;

-- 4. A free-text description so a DM can search the activity by what it is called on the day.
alter table activities add column if not exists description text;
alter table activities add column if not exists aka text;        -- other names people use for it

-- 5. Everything an activity needs, in one list.
drop view if exists v_activity_requirements cascade;
create view v_activity_requirements with (security_invoker = true) as
  select r.act_id, 'Competency'::text as kind, c.id as item_id,
         c.name || ' (L' || c.level || ')' as item_name, r.role, false as everyone
    from activity_comps r join competencies c on c.id = r.comp_id
  union all
  select a.id, 'Competency', c.id, c.name || ' (L' || c.level || ')', 'Instructor', true
    from activities a cross join competencies c where c.required_for_all
  union all
  select a.id, 'AMP', m.id, m.title, 'Instructor', false
    from activities a join amps m on m.act_id = a.id
  union all
  select x.act_id, 'AMP', m.id, m.title, 'Instructor', false
    from activity_amps x join amps m on m.id = x.amp_id
  union all
  select a.id, 'AMP', m.id, m.title, 'Instructor', true
    from activities a cross join amps m where m.required_for_all;

-- 6. Who is ready for an activity, and what they are short of.
drop view if exists v_activity_ready;
create view v_activity_ready with (security_invoker = true) as
with req as (select * from v_activity_requirements),
chk as (
  select i.id as instructor_id, r.act_id, r.kind, r.item_name, r.role,
         case when r.kind = 'Competency'
              then exists (select 1 from v_competency_status s
                           where s.instructor_id = i.id and s.comp_id = r.item_id and s.status = 'Competent')
              else exists (select 1 from v_amp_status s
                           where s.instructor_id = i.id and s.amp_id = r.item_id and s.up_to_date)
         end as ok
  from instructors i join req r on true
  where i.account_type = 'instructor' and i.employment <> 'Past staff'
)
select instructor_id, act_id,
       bool_and(ok) as ready,
       count(*) filter (where not ok) as missing_count,
       string_agg(case when not ok then kind || ': ' || item_name end, ' · ' order by kind, item_name) as missing
from chk group by instructor_id, act_id;

alter table activity_comps enable row level security;
alter table activity_amps  enable row level security;
drop policy if exists act_comps_read on activity_comps;
drop policy if exists act_comps_write on activity_comps;
drop policy if exists act_amps_read on activity_amps;
drop policy if exists act_amps_write on activity_amps;
create policy act_comps_read  on activity_comps for select to authenticated using (true);
create policy act_comps_write on activity_comps for all    to authenticated using (is_manager()) with check (is_manager());
create policy act_amps_read   on activity_amps  for select to authenticated using (true);
create policy act_amps_write  on activity_amps  for all    to authenticated using (is_manager()) with check (is_manager());
grant select on v_activity_requirements, v_activity_ready to authenticated;
revoke all on v_activity_requirements, v_activity_ready from anon;

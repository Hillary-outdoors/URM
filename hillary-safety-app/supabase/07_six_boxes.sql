-- URMA · step 7 · Six kinds of tick box, named as on the paper forms
-- Run this once in Supabase (SQL Editor) BEFORE loading the trial data. Safe to run again.
--
-- Why: the 2024 competency forms do not all use the same boxes. Some have two
-- observation boxes, some have up to three assessor boxes (canoe / sea kayak / sit-on),
-- and each form prints its own box names. This step lets the database hold all of them.

-- 1. Two more box types on each line: a second observation and a third assessor box.
alter table competency_lines add column if not exists needs_obs2    boolean not null default false;
alter table competency_lines add column if not exists needs_assess3 boolean not null default false;

-- 2. Each competency keeps the box names from its own form, e.g. {"obs1":"Peer","assess1":"Assess site 1"}.
--    "code" is a short fixed label (e.g. TL1-08) so data loads can find the right competency.
alter table competencies add column if not exists box_labels jsonb not null default '{}'::jsonb;
alter table competencies add column if not exists code text;
create unique index if not exists competencies_code_key on competencies(code);

-- 3. Ticks can now be any of the six types, and can say they came from a paper folder or the old matrix.
alter table comp_signoffs drop constraint if exists comp_signoffs_tick_type_check;
alter table comp_signoffs add  constraint comp_signoffs_tick_type_check
  check (tick_type in ('self','obs1','obs2','assess1','assess2','assess3'));
alter table comp_signoffs drop constraint if exists comp_signoffs_source_check;
alter table comp_signoffs add  constraint comp_signoffs_source_check
  check (source in ('self','manual','training_log','override','scan','backfill'));

-- 4. People keep a short note of site or craft limits, e.g. "Okupata only".
alter table qualifications_held add column if not exists notes text;

-- 5. Work out the status again, now counting all six box types.
--    Indirect = every Self and Observation box ticked. Competent = every box ticked.
drop view if exists v_competency_status;
create view v_competency_status with (security_invoker = true) as
with required as (
  select l.comp_id, l.id as line_id, l.auto_from_amp, t.tick_type
  from competency_lines l
  cross join lateral (values ('self', l.needs_self), ('obs1', l.needs_obs1), ('obs2', l.needs_obs2),
                             ('assess1', l.needs_assess1), ('assess2', l.needs_assess2), ('assess3', l.needs_assess3)) as t(tick_type, needed)
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
  where i.account_type = 'instructor' and i.employment <> 'Past staff'
),
totals as (
  select instructor_id, comp_id,
         count(*)                                                        as total,
         count(*) filter (where done)                                    as done,
         count(*) filter (where done and not auto_from_amp)              as real_done,
         count(*) filter (where not auto_from_amp and tick_type in ('self','obs1','obs2'))          as so_total,
         count(*) filter (where done and not auto_from_amp and tick_type in ('self','obs1','obs2')) as so_done
  from ticks group by instructor_id, comp_id
)
select c.id as comp_id, c.name, c.level, c.act_id, c.centre_id,
       i.id as instructor_id, i.name as instructor_name,
       coalesce(t.total, 0) as total, coalesce(t.done, 0) as done,
       case when coalesce(t.total, 0) = 0 then 'Not started'
            when t.done = t.total       then 'Competent'
            when t.real_done = 0        then 'Not started'
            when t.so_total > 0 and t.so_done = t.so_total then 'Indirect'
            else 'Direct' end as status,
       c.box_labels, c.code
from competencies c
cross join instructors i
left join totals t on t.comp_id = c.id and t.instructor_id = i.id
where i.account_type = 'instructor' and i.employment <> 'Past staff';

grant select on v_competency_status to authenticated;
revoke all on v_competency_status from anon;

-- 6. Initials, as written in the box on the paper form.
alter table comp_signoffs add column if not exists initials text;

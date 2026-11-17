-- URMA · step 24 · Make the competency status fast
--
-- The old view asked "is this box ticked?" once per person per box — about 400,000 little lookups
-- every time anything read it, whoever you had searched for. On Supabase that runs past the
-- statement timeout and comes back as a 500. This does the same sums as two joins and a group-by.
--
-- Safe to run again. It does not change any answer, only the speed.

create index if not exists comp_signoffs_line_tick on comp_signoffs (line_id, tick_type);
create index if not exists competency_lines_comp on competency_lines (comp_id);
create index if not exists amps_act on amps (act_id);
create index if not exists competencies_act on competencies (act_id);

drop view if exists v_activity_ready;
drop view if exists v_intention_ready;
drop view if exists v_competency_status;

create view v_competency_status with (security_invoker = true) as
with req as (                                   -- every box the forms actually ask for
  select l.comp_id, l.id as line_id, l.auto_from_amp, t.tick_type
  from competency_lines l
  cross join lateral (values ('self', l.needs_self), ('obs1', l.needs_obs1), ('obs2', l.needs_obs2),
                             ('assess1', l.needs_assess1), ('assess2', l.needs_assess2), ('assess3', l.needs_assess3)) as t(tick_type, needed)
  where t.needed
),
tot as (                                        -- how many boxes each competency has
  select comp_id,
         count(*)                                                                              as total,
         count(*) filter (where auto_from_amp)                                                 as amp_total,
         count(*) filter (where not auto_from_amp and tick_type in ('self','obs1','obs2'))     as so_total
  from req group by comp_id
),
got as (                                        -- how many of them each person has, in one pass
  select s.instructor_id, r.comp_id,
         count(*)                                                        as done,
         count(*) filter (where r.tick_type in ('self','obs1','obs2'))   as so_done
  from comp_signoffs s
  join req r on r.line_id = s.line_id and r.tick_type = s.tick_type and not r.auto_from_amp
  group by 1, 2
),
ampgot as (                                     -- lines that tick themselves when the AMP is signed
  select k.instructor_id, c.id as comp_id, t.amp_total as done
  from amp_acknowledgements k
  join amps a on a.id = k.amp_id and k.amp_version = a.version and a.version > 0
  join competencies c on c.act_id = a.act_id
  join tot t on t.comp_id = c.id
  where t.amp_total > 0
)
select c.id as comp_id, c.name, c.level, c.act_id, c.centre_id, c.box_labels, c.code,
       i.id as instructor_id, i.name as instructor_name,
       coalesce(t.total, 0)                                           as total,
       coalesce(g.done, 0) + coalesce(ag.done, 0)                     as done,
       case when coalesce(t.total, 0) = 0                      then 'Not started'
            when coalesce(g.done,0) + coalesce(ag.done,0) >= t.total then 'Competent'
            when coalesce(g.done, 0) = 0                       then 'Not started'
            when t.so_total > 0 and g.so_done >= t.so_total    then 'Indirect'
            else 'Direct' end                                          as status
from competencies c
cross join instructors i
left join tot    t  on t.comp_id = c.id
left join got    g  on g.comp_id = c.id and g.instructor_id = i.id
left join ampgot ag on ag.comp_id = c.id and ag.instructor_id = i.id
where i.account_type = 'instructor' and i.employment <> 'Past staff';

-- the two views that sit on top of it, rebuilt unchanged
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

grant select on v_competency_status, v_activity_ready, v_intention_ready to authenticated;
revoke all on v_competency_status, v_activity_ready, v_intention_ready from anon;
analyze comp_signoffs;
analyze competency_lines;

-- URMA · step 20 · Tidy up what the half-finished import left behind
--
-- Your database shows 91 activities and 91 AMPs; the current set is 80. The extra 11 are rows the
-- first import created under names that have since changed (the ones that needed "(Coromandel)" or
-- "(Tertiary)" on the end because two AMPs share a number). This removes only activities that have
-- no AMP content from the current load and are not used by anything.
--
-- It also shows you whether the optional folder ticks are in the database, and removes them if you
-- say so. Read each step before running it. Safe to run again.

-- 1. What is actually there. Run this on its own first.
select 'activities not in the current set' as what, count(*) as n
from activities a
where not exists (select 1 from amps m where m.act_id = a.id and m.change_summary is not null)
union all
select 'ticks read from the scanned folders', count(*)
from comp_signoffs where source = 'scan' and reason like 'Read from the scanned paper folder%'
union all
select 'sign-offs from the Completed/RRCC box', count(*)
from comp_signoffs where reason like 'Completed/RRCC%';

-- 2. Remove the leftover activities. Nothing is lost: the current AMPs are on the kept rows.
--    (Delete the two dashes at the start of each line to run it.)
-- delete from activity_comps where act_id in (
--   select a.id from activities a
--   where not exists (select 1 from amps m where m.act_id = a.id and m.change_summary is not null)
--     and not exists (select 1 from intention_activities x where x.act_id = a.id));
-- delete from amp_hazards where amp_id in (
--   select m.id from amps m join activities a on a.id = m.act_id
--   where m.change_summary is null
--     and not exists (select 1 from intention_activities x where x.act_id = a.id));
-- delete from amps where change_summary is null;
-- delete from activities a
--  where not exists (select 1 from amps m where m.act_id = a.id)
--    and not exists (select 1 from intention_activities x where x.act_id = a.id);

-- 3. Remove the folder ticks, if you decided against them.
--    This leaves the Completed/RRCC sign-offs and the matrix back-fill alone.
-- delete from comp_signoffs where source = 'scan' and reason like 'Read from the scanned paper folder%';

-- 4. Check again.
select 'activities' as t, count(*) as n from activities
union all select 'amps', count(*) from amps
union all select 'amp_hazards', count(*) from amp_hazards
union all select 'comp_signoffs', count(*) from comp_signoffs
order by 1;

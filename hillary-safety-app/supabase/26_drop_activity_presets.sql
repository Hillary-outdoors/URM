-- URMA · step 26 · Remove the activity descriptions
--
-- They were a good idea on paper but they made the day sheet and "Who can run what" harder to use
-- than the thing they replaced. An intention is now worded however the instructor likes, and the DM
-- pins the competencies and AMPs onto it. The AMP-shaped activities stay: they are what an
-- intention records, and what decides whether a trip needs calling in.
--
-- Safe to run again. Nothing is lost that cannot be re-added.

begin;
-- The column only exists if step 25 was ever run. Adding it here means this file works either way.
alter table activities add column if not exists preset boolean not null default false;
delete from activity_comps where act_id in (select id from activities where preset);
delete from activity_amps  where act_id in (select id from activities where preset);
delete from activities a
 where a.preset
   and not exists (select 1 from intention_activities x where x.act_id = a.id)
   and not exists (select 1 from amps m where m.act_id = a.id);
commit;

select count(*) filter (where preset) as presets_left, count(*) as activities from activities;
-- expect presets_left 0, activities 80

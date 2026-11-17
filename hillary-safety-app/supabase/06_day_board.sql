-- =====================================================================
-- FILE 6: THE DAY BOARD
-- Run this on its own, in the Supabase SQL Editor, after files 1 to 4.
-- It is safe to run on a database that is already in use: it only adds
-- a new read-only view and changes nothing that is already there.
--
-- What it does: lets instructors see who else is out on a given day, so
-- they can work out how the day fits together. It shows the plan, the
-- times and who is on each trip. It does NOT show the DM's private
-- notes or the notes written after the day.
-- =====================================================================

create or replace view v_day_board as
select
  i.id            as intention_id,
  i.date,
  i.centre_id,
  c.name          as centre_name,
  i.group_name,
  i.pax,
  i.outcome_of_day,
  i.plan,
  i.overnight,
  i.started_at,
  i.due_by,
  i.called_in_at,
  i.called_in_as,
  i.status,
  (select coalesce(string_agg(p.name, ' + ' order by p.name), '')
     from intention_instructors ii
     join instructors p on p.id = ii.instructor_id
    where ii.intention_id = i.id)                      as instructor_names,
  (select coalesce(array_agg(ii.instructor_id), '{}')
     from intention_instructors ii
    where ii.intention_id = i.id)                      as instructor_ids,
  (select coalesce(string_agg(a.name, ' + ' order by a.name), '')
     from intention_activities ia
     join activities a on a.id = ia.act_id
    where ia.intention_id = i.id)                      as activity_names,
  (select coalesce(array_agg(ia.act_id), '{}')
     from intention_activities ia
    where ia.intention_id = i.id)                      as act_ids,
  -- Does this trip need calling in? Cave, water, mountain or overnight.
  (i.overnight or exists (select 1
                            from intention_activities ia
                            join activities a on a.id = ia.act_id
                           where ia.intention_id = i.id
                             and a.call_in_type <> 'None'))  as needs_call_in
from intentions i
join centres c on c.id = i.centre_id;

-- The view deliberately runs with the owner's rights, so every signed-in
-- person sees the whole day. The columns above are the only ones it shows:
-- dm_notes and debrief_notes are not in it.
alter view v_day_board set (security_invoker = false);

revoke all on v_day_board from anon;
grant select on v_day_board to authenticated;

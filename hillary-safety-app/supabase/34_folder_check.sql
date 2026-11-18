-- URMA · step 34 · Copying the paper folders in, quickly
--
-- Going through 48 folders box by box, with a form to fill in for every tick, is days of work.
-- This adds a source of 'folder' that means exactly what it says: this tick was copied off the
-- paper, during the one-off cross-check, rather than signed off in the app.
--
-- A folder tick does not need a reason typed against it, the way a manager's one-off override
-- does. Saying where it came from IS the reason, and it is recorded on every row, so these can
-- always be told apart from ticks made in the app afterwards - or pulled back out again if the
-- cross-check turns out to have gone wrong.
--
-- Safe to run again.

begin;

alter table comp_signoffs drop constraint if exists comp_signoffs_source_check;
alter table comp_signoffs add  constraint comp_signoffs_source_check
  check (source in ('self', 'manual', 'training_log', 'override', 'scan', 'backfill', 'folder'));

-- The old rule: anything that is not a Self tick must name a signer and give a reason, unless it
-- came from a training log. A folder tick joins training logs in that exemption.
alter table comp_signoffs drop constraint if exists comp_signoffs_check;
alter table comp_signoffs add  constraint comp_signoffs_check
  check (tick_type = 'self'
         or (signed_by is not null and (source in ('training_log', 'folder', 'scan', 'backfill')
                                        or reason is not null)));

create index if not exists comp_signoffs_folder on comp_signoffs (source) where source = 'folder';

commit;

-- How the cross-check is going. Run it whenever you want to see where you are up to.
select i.name,
       count(*) filter (where s.source = 'folder')  as copied_from_the_folder,
       count(*)                                     as ticks_in_total
  from comp_signoffs s join instructors i on i.id = s.instructor_id
 group by i.name having count(*) filter (where s.source = 'folder') > 0
 order by 2 desc;

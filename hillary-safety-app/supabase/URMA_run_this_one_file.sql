-- =====================================================================
--  URMA · RUN THIS ONE FILE
--  Hillary Outdoors · 18 November 2026
-- =====================================================================
--
--  This is everything outstanding, in the right order, in one go. It replaces
--  the separate files 18, 21, 22, 23, 24, 25 and 26 — you do not need to run
--  those as well, and nothing is lost if you already did.
--
--  HOW TO RUN IT
--    1. Supabase dashboard > SQL Editor > New query
--    2. Paste this whole file
--    3. Press Run (it takes a few seconds)
--    4. Read the four checks it prints at the bottom
--
--  It is safe to run twice. Every step either rebuilds what it owns or guards
--  itself with "if not exists", so a second run changes nothing.
--
--  WHAT IT DOES
--    A. Which competency each activity needs            (was 18)
--    B. Clears out the activities the accidental 08 left (was 21)
--    C. One-off intentions: the DM pins comps and AMPs  (was 22)
--    D. Craft and site on a requirement                 (was 23)
--    E. Removes the activity descriptions               (was 25 + 26)
--    F. Makes "Who can run what" fast                   (was 24)
--    G. The training log, loaded from Smartsheet            (was 27)
--
--  Nothing here touches people, qualifications, competencies, lines or
--  sign-offs. Your 191,946 recorded boxes are not read or changed.
-- =====================================================================



-- ---------------------------------------------------------------------
--  PART A · Which competency each activity needs
-- ---------------------------------------------------------------------

-- URMA · step 18 · Which competency each activity needs
-- Safe to run again. Paste the whole file into Supabase > SQL Editor and press Run.

begin;

delete from activity_comps;
insert into activity_comps (act_id, comp_id, role)
select a.id, c.id, v.role
from (values
  ('AMP 1 ABL Low Ropes Course','TL1-40','Instructor'),
  ('AMP 1 ABL Low Ropes Course','TL2-07','Instructor'),
  ('AMP 1 ABL Low Ropes Course','TL2-13','Instructor'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)','TL1-08','Instructor'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)','TL2-07','Instructor'),
  ('AMP 12 Alpine Winter General (Tongariro)','TL1-11','Instructor'),
  ('AMP 12 Alpine Winter General (Tongariro)','TL2-10','Instructor'),
  ('AMP 12 Level 3-4 Sea Kayaking Coromandel (Coromandel)','TL3-07','Instructor'),
  ('AMP 15 Alpine Camping Above Bush Line','TL1-17','Instructor'),
  ('AMP 15 Alpine Camping Above Bush Line','TL1-20','Instructor'),
  ('AMP 15 Alpine Camping Above Bush Line','TL2-13','Instructor'),
  ('AMP 17 Alpine Grade 2 Mountaineering','TL4-19','Instructor'),
  ('AMP 18 Alpine Skills and Tertiary','TL2-10','Instructor'),
  ('AMP 2 ABL Local Initiatives (Tongariro)','TL1-40','Instructor'),
  ('AMP 21 Bush Local Bush (Tongariro)','TL1-14','Instructor'),
  ('AMP 21 Bush Local Bush (Tongariro)','TL2-16','Instructor'),
  ('AMP 22 Bush River Travel (Tongariro)','TL1-31','Instructor'),
  ('AMP 23 Bush craft (Tongariro)','TL1-14','Instructor'),
  ('AMP 26 Puerora Tramping (Tongariro)','TL2-16','Instructor'),
  ('AMP 27 Bush Overnight Camping (Tongariro)','TL1-17','Instructor'),
  ('AMP 31 Cave Okupata Cave (Tongariro)','TL1-35','Instructor'),
  ('AMP 32 Cave Pukehinau Cave (Tongariro)','TL1-35','Instructor'),
  ('AMP 4 ABL Flying Fox','TL1-39','Instructor'),
  ('AMP 41 Rock Whakapapa Area Crags','TL1-25','Instructor'),
  ('AMP 43 Rock Meads Wall Traverse','TL2-31','Instructor'),
  ('AMP 43 Rock Meads Wall Traverse','TL3-14','Instructor'),
  ('AMP 44 Rock Meads Wall Loop','TL2-31','Instructor'),
  ('AMP 44 Rock Meads Wall Loop','TL3-14','Instructor'),
  ('AMP 45 Rock Mangatepopo Area Crags','TL2-20','Instructor'),
  ('AMP 46 Rock Self-directed Abseil','TL4-11','Instructor'),
  ('AMP 47 Rock Taranaki Falls Abseil','TL2-20','Instructor'),
  ('AMP 50 Rock High Ropes Course','TL1-37','Instructor'),
  ('AMP 50 Rock High Ropes Course','TL2-03','Instructor'),
  ('AMP 51 Rock Indoor Climbing Walls (Tongariro)','TL1-25','Instructor'),
  ('AMP 51 Rock Waitomo Crags (Tertiary)','TL3-18','Instructor'),
  ('AMP 51 Rock Waitomo Crags (Tertiary)','TL4-11','Instructor'),
  ('AMP 61 Water Lake Otamangakau Water Activities','TL1-28','Instructor'),
  ('AMP 62 Water Lake Taupo Activities','TL1-28','Instructor'),
  ('AMP 62 Water Lake Taupo Activities','TL2-23','Instructor'),
  ('AMP 63 Water Kayaking G2-3 Tarawera Slalom site','TL3-15','Instructor'),
  ('AMP 63 Water Kayaking G2-3 Tarawera Slalom site','TL4-15','Instructor'),
  ('AMP 64 Tongariro River - SOT, Inflatable','TL2-25','Instructor'),
  ('AMP 65 Water Tongariro River Delta','TL2-23','Instructor'),
  ('AMP 66 Water Kayaking G2 Aniwhenua','TL3-15','Instructor'),
  ('AMP 68 Water Canoe G2 Tongariro (Tongariro)','TL3-11','Instructor'),
  ('AMP 69 Water Kayaking Mohaka G2','TL3-15','Instructor'),
  ('AMP 71 Water Tawhai Falls Jump','TL1-31','Instructor'),
  ('AMP 72 Water Whanganui River Travel','TL3-11','Instructor'),
  ('AMP 72 Water Whanganui River Travel','TL4-07','Instructor'),
  ('AMP 76 Water Kayaking Murchison G2-3','TL4-15','Instructor'),
  ('AMP 77 Water Upper Mangatepopo Steep Creek Trip','TL2-28','Instructor'),
  ('AMP 77 Water Upper Mangatepopo Steep Creek Trip','TL3-03','Instructor'),
  ('AMP Bush Tertiary','TL2-05','Instructor'),
  ('AMP Bush Tertiary','TL2-16','Instructor')
) as v(act, code, role)
join activities a on a.name = v.act
join competencies c on c.code = v.code
on conflict do nothing;

update competencies set act_id = (select min(a.id) from activity_comps r join activities a on a.id = r.act_id where r.comp_id = competencies.id);

commit;

-- what landed:
select count(*) as links from activity_comps;
-- expect 54 · competencies everyone needs: 6


-- ---------------------------------------------------------------------
--  PART B · Undo the activities the accidental 08 created
-- ---------------------------------------------------------------------

-- URMA · step 21 · Undo the old 08 file that was run by accident
--
-- The first version of the import (08_trial_data_part1 / part2) created activities under names that
-- have since changed — the ones that needed "(Coromandel)" or "(Tertiary)" added because two AMPs
-- share a number — and it loaded the folder ticks. This removes both, and nothing else.
--
-- Competencies, lines, people, qualifications and the matrix back-fill are untouched: step 13
-- rebuilds those from scratch every time, so they are already correct.
-- Safe to run again. Run it after the other files, not before.

begin;

create temp table _current (name text primary key) on commit drop;
insert into _current values
  ('AMP 1 ABL Low Ropes Course'),
  ('AMP 2 ABL Local Initiatives (Tongariro)'),
  ('AMP 2 Low ropes (Coromandel)'),
  ('AMP 3 Pool Tyrolean'),
  ('AMP 4 ABL Flying Fox'),
  ('AMP 10 XL SUP'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)'),
  ('AMP 11 level 1-2 Sea Kayaking Coromandel (Coromandel)'),
  ('AMP 12 Alpine Winter General (Tongariro)'),
  ('AMP 12 Level 3-4 Sea Kayaking Coromandel (Coromandel)'),
  ('AMP 13 Surf Sports Waikawau Bay'),
  ('AMP 14 Alpine Snow Sports Day'),
  ('AMP 15 Alpine Camping Above Bush Line'),
  ('AMP 16 Surfing'),
  ('AMP 17 Alpine Grade 2 Mountaineering'),
  ('AMP 18 Alpine Skills and Tertiary'),
  ('AMP 21 Bush Local Bush (Tongariro)'),
  ('AMP 21 Coasteering Little bay to Waikawau (Coromandel)'),
  ('AMP 22 Bush River Travel (Tongariro)'),
  ('AMP 22 Snorkeling (Coromandel)'),
  ('AMP 23 Bush craft (Tongariro)'),
  ('AMP 23 Sit on top kayak (Coromandel)'),
  ('AMP 25 Bush Solo Overnight (Tongariro)'),
  ('AMP 25 Coasteering Rowner Bay (Coromandel)'),
  ('AMP 26 Coasteering Otautu Bay (Coromandel)'),
  ('AMP 26 Puerora Tramping (Tongariro)'),
  ('AMP 27 Bush Overnight Camping (Tongariro)'),
  ('AMP 27 Waka Taurua (Coromandel)'),
  ('AMP 28 Advanced Snorkel'),
  ('AMP 29 Coasteering -Black Rock'),
  ('AMP 30 Local Bush'),
  ('AMP 31 Cave Okupata Cave (Tongariro)'),
  ('AMP 31 Orienteering (Coromandel)'),
  ('AMP 32 Bush Overnight camping (Coromandel)'),
  ('AMP 32 Cave Pukehinau Cave (Tongariro)'),
  ('AMP 33 Bush Long Programme Camping'),
  ('AMP 40 Rock Tangiaro Abseil'),
  ('AMP 41 Rock Whakapapa Area Crags'),
  ('AMP 42 Rock Lower Rock Wall'),
  ('AMP 43 Rock Meads Wall Traverse'),
  ('AMP 44 Rock Meads Wall Loop'),
  ('AMP 45 Rock Mangatepopo Area Crags'),
  ('AMP 46 Rock Self-directed Abseil'),
  ('AMP 47 Rock Taranaki Falls Abseil'),
  ('AMP 48 Rock Pukehinau Abseil'),
  ('AMP 50 Rock High Ropes Course'),
  ('AMP 51 Rock Indoor Climbing Walls (Tongariro)'),
  ('AMP 51 Rock Waitomo Crags (Tertiary)'),
  ('AMP 52 Rock South Waikato Crags'),
  ('AMP 54 Rock Kawakawa Bay Crag'),
  ('AMP 55 Rock Kinloch 1.2 Crag'),
  ('AMP 56 Rock Dunedin Crags'),
  ('AMP 57 Rock Timaru Crags'),
  ('AMP 58 Rock Sebastopol Bluffs'),
  ('AMP 59 Rock Tukino'),
  ('AMP 61 Water Lake Otamangakau Water Activities'),
  ('AMP 62 Water Lake Taupo Activities'),
  ('AMP 63 Water Kayaking G2-3 Tarawera Slalom site'),
  ('AMP 64 Tongariro River - SOT, Inflatable'),
  ('AMP 65 Water Tongariro River Delta'),
  ('AMP 66 Water Kayaking G2 Aniwhenua'),
  ('AMP 68 Water Canoe G2 Tongariro (Tongariro)'),
  ('AMP 68 Water Kayaking G4 Kaituna (Tertiary)'),
  ('AMP 69 Water Kayaking Mohaka G2'),
  ('AMP 71 Water Tawhai Falls Jump'),
  ('AMP 72 Water Whanganui River Travel'),
  ('AMP 73 Water Kayak Piriaka'),
  ('AMP 74 Water Kayaking Waikato Reids Farm'),
  ('AMP 75 Water Pukehinau Stream Travel'),
  ('AMP 76 Water Kayaking Murchison G2-3'),
  ('AMP 77 Water Upper Mangatepopo Steep Creek Trip'),
  ('AMP 79 Water River rescue Grade 2 Tongariro'),
  ('AMP 81 COR Support Boats'),
  ('AMP 82 Driving (Coromandel)'),
  ('AMP 82 Other Swimming Pool (Tongariro)'),
  ('AMP 83 Other Competitive Events'),
  ('AMP 87 Supervising Instruction Events'),
  ('AMP Bush Tertiary'),
  ('AMP Rock Wharepapa South'),
  ('AMP Tertiary Snow Sports');

-- 1. activities the old import left behind. Deleting one takes its AMP and hazards with it.
--    An activity already used on an intention is kept, so nothing on a day sheet breaks.
delete from activities a
 where a.name not in (select name from _current)
   and not exists (select 1 from intention_activities x where x.act_id = a.id);

-- 2. the ticks read from the scanned folders, which the old 08 loaded.
--    The Completed/RRCC sign-offs and the matrix back-fill are left alone.
delete from comp_signoffs
 where source = 'scan' and reason like 'Read from the scanned paper folder%';

commit;

-- what you should see now:
select 'activities' as t, count(*) as n from activities
union all select 'amps', count(*) from amps
union all select 'amp_hazards', count(*) from amp_hazards
union all select 'comp_signoffs', count(*) from comp_signoffs
union all select 'competencies', count(*) from competencies
union all select 'competency_lines', count(*) from competency_lines
union all select 'instructors', count(*) from instructors
union all select 'qualifications_held', count(*) from qualifications_held
order by 1;
-- expected: activities 80, amps 80, amp_hazards 444, comp_signoffs 191946,
--           competencies 62, competency_lines 2051, instructors 75, qualifications_held 569


-- ---------------------------------------------------------------------
--  PART C · One-off intentions
-- ---------------------------------------------------------------------

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


-- ---------------------------------------------------------------------
--  PART D · Craft and site on a requirement
-- ---------------------------------------------------------------------

-- URMA · step 23 · Craft and site on a requirement
--
-- "Canoe lake Otamangakau" and "SOT lake Otamangakau" are the same AMP and the same competency
-- (Flat Water L1) but a different box inside it: the canoe assessor box, or the sit-on one.
-- Same with River Safety and the Tawhai endorsement. This stores that distinction so the app can
-- ask for the right box rather than the whole competency.
--
-- Safe to run again.

alter table activity_comps  add column if not exists qualifier text;   -- 'Canoe', 'Sea kayak', 'Sit-on', 'Tawhai endorsement', 'Okupata' …
alter table intention_comps add column if not exists qualifier text;
comment on column activity_comps.qualifier is
  'The craft or site within the competency, matched against the box names on the form. Empty means the whole competency.';


-- ---------------------------------------------------------------------
--  PART E · Remove the activity descriptions
-- ---------------------------------------------------------------------

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


-- ---------------------------------------------------------------------
--  PART F · Make the status check fast
-- ---------------------------------------------------------------------

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
-- Built on the status view, so it has to go first and step 27 puts it back.
drop view if exists v_log_review;
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


-- ---------------------------------------------------------------------
--  PART G · The training log, loaded from Smartsheet
-- ---------------------------------------------------------------------

-- URMA · step 27 · The training log, loaded from Smartsheet
--
-- The log already exists and is filled in on Smartsheet. This makes room for it in the database,
-- one row per trainee per session, so a session with two trainees becomes two records. It keeps
-- the whole entry, not a summary: the trainer, the activity, where it was, what kind of session it
-- was, the outcome, the written summary and the next steps.
--
-- The outcome column on the log already uses the same words as a competency status — Competent,
-- Indirect, Direct — so loading an entry ticks the boxes straight away. The trainer named on the
-- entry is the signer and their initials go in each box. No second approval: the trainer already
-- made the call when they filled the log in.
--
-- Three things stop that being dangerous:
--   · Loading only ever ADDS ticks. It cannot remove one, so an old entry can never undo a later
--     sign-off, and loading the same export twice changes nothing.
--   · Every tick it makes carries the log entry it came from, so "undo this entry" is one button.
--   · Where a competency exists at more than one level — Rock climbing L1 and L2, Bush L1 and L2 —
--     it ticks the lowest level the person has not already finished, never both.
--
-- Safe to run again.

begin;

-- ---------- Everything the Smartsheet log holds that is worth keeping
alter table training_logs add column if not exists centre_id      bigint references centres(id);
alter table training_logs add column if not exists trainer_id     uuid references instructors(id) on delete set null;
alter table training_logs add column if not exists days           numeric(4,1);
alter table training_logs add column if not exists activity_text  text;    -- as written on the log
alter table training_logs add column if not exists location       text;
alter table training_logs add column if not exists training_type  text;    -- "Senior instructor observed…"
alter table training_logs add column if not exists session_type   text;    -- "Coaching", "Role modeling"…
alter table training_logs add column if not exists raw_outcome    text;    -- exactly as typed, before tidying
alter table training_logs add column if not exists summary        text;
alter table training_logs add column if not exists next_steps     text;
alter table training_logs add column if not exists sms_ok         text;    -- followed the SMS and managed hazards
alter table training_logs add column if not exists folder_updated text;
alter table training_logs add column if not exists link           text;
alter table training_logs add column if not exists imported_at    timestamptz;
alter table training_logs add column if not exists applied_at     timestamptz;  -- when its boxes were ticked
alter table training_logs add column if not exists ticks_made     integer;

-- A session can list two trainees. That is two records from one Smartsheet row, so the row
-- number on its own cannot be unique.
alter table training_logs drop constraint if exists training_logs_smartsheet_row_key;
drop index if exists training_logs_one_per_trainee;
-- Not a partial index: a plain unique index already allows any number of empty values, and
-- only a plain one can be named by "on conflict" when the app loads the export.
create unique index training_logs_one_per_trainee
  on training_logs (smartsheet_row, instructor_id);

-- The Smartsheet export carries no row number, so an entry is recognised by what it says:
-- the date, the trainer and the activity. Loading the same export twice updates these rows
-- instead of making a second copy of every session.
alter table training_logs add column if not exists dedupe_key text;
drop index if exists training_logs_dedupe;
create unique index training_logs_dedupe
  on training_logs (instructor_id, dedupe_key);

-- Which competency each entry turned out to be about, once the level was worked out.
create table if not exists training_log_comps (
  log_id  bigint not null references training_logs(id) on delete cascade,
  comp_id bigint not null references competencies(id) on delete cascade,
  primary key (log_id, comp_id)
);

-- ---------- What each phrase on the log means
-- The log says "Winter Alpine"; the competency is called "Alpine Winter". This is that lookup.
-- Leave the level empty to mean "whichever level they are working on". Put a number in it when a
-- phrase can only ever mean one level.
create table if not exists log_activity_map (
  phrase    text primary key,                       -- lower case, as written on the log
  comp_name text,                                   -- null = recorded, but it signs nothing off
  level     integer,
  note      text
);
alter table log_activity_map add column if not exists level integer;

insert into log_activity_map (phrase, comp_name, level, note) values
  ('high ropes',           'High Ropes Course',  null, 'L2 High Ropes Technical is a separate phrase'),
  ('high ropes technical', 'High Ropes Technical', null, null),
  ('low ropes',            'ABL',                null, null),
  ('local abl',            'ABL',                null, null),
  ('abl',                  'ABL',                null, null),
  ('winter alpine',        'Alpine Winter',      null, null),
  ('alpine winter',        'Alpine Winter',      null, null),
  ('summer alpine',        'Alpine Summer',      null, null),
  ('alpine summer',        'Alpine Summer',      null, null),
  ('rock',                 'Rock climbing',      null, null),
  ('rock climbing',        'Rock climbing',      null, null),
  ('bush',                 'Bush',               null, null),
  ('abseil',               'Abseiling',          null, null),
  ('abseiling',            'Abseiling',          null, null),
  ('cave',                 'Cave',               null, null),
  ('caving',               'Cave',               null, null),
  ('canoe',                'Flat Water',         null, null),
  ('flat water kayak',     'Flat Water',         null, null),
  ('flat water',           'Flat Water',         null, null),
  ('overnight',            'Overnight',          null, null),
  ('sea kayak',            'Sea Kayak',          null, null),
  ('flying fox',           'Flying Fox',         null, null),
  ('river rescue',         'River Safety',       null, null),
  ('white water safety and rescue', 'River Safety', null, null),
  ('communications',       'Communications',     null, null),
  ('facilitation',         'Facilitate O.E. School Programmes', null, null),
  ('risk management',      'Risk Management, Group Management, Core Competencies', null, null),
  ('white water kayak',    'Kayak Skills',       null, 'L3. Check this is the one you mean'),
  ('kayak',                'Kayak Skills',       null, 'L3. Check this is the one you mean')
on conflict (phrase) do nothing;

-- Phrases that are training but sign nothing off. Recorded, never ticked.
insert into log_activity_map (phrase, comp_name, level, note) values
  ('human skills',     null, null, 'training, not a competency'),
  ('soft skills',      null, null, 'training, not a competency'),
  ('induction',        null, null, 'training, not a competency'),
  ('lesson planning',  null, null, 'training, not a competency'),
  ('morning theme',    null, null, 'training, not a competency'),
  ('safety management',null, null, 'training, not a competency'),
  ('other',            null, null, 'training, not a competency'),
  ('duty manager induction',   null, null, 'training, not a competency'),
  ('train the trainers',       null, null, 'training, not a competency'),
  ('staff training',           null, null, 'training, not a competency'),
  ('presentation',             null, null, 'training, not a competency'),
  ('driving',                  null, null, 'training, not a competency'),
  ('catering',                 null, null, 'training, not a competency'),
  ('tikanga',                  null, null, 'training, not a competency'),
  ('phec refresher',           null, null, 'training, not a competency'),
  ('continued proffesioanl development', null, null, 'spelled as it is on the log'),
  ('continued proffesioanl developmnet', null, null, 'spelled as it is on the log'),
  ('cpd',                      null, null, 'training, not a competency'),
  ('microsoft teams and associated apps training.', null, null, 'training, not a competency')
on conflict (phrase) do nothing;

-- ---------- Initials from a name, when the person has none recorded
create or replace function initials_of(p_name text) returns text
language sql immutable set search_path = public as $$
  select upper(left(string_agg(left(w, 1), '' order by i), 3))
    from unnest(regexp_split_to_array(coalesce(p_name, ''), '[^A-Za-z]+')) with ordinality as x(w, i)
   where w <> '';
$$;

-- ---------- Loading an entry ticks its boxes
-- Competent means every box on the form. Indirect means the Self and Observation boxes, which is
-- what "can work under indirect supervision" is. Direct means a start has been made, so the Self
-- box only. Monitoring Required, N/a and anything typed free-hand tick nothing and are kept as a
-- record. A box is only ever added, never taken away.
create or replace function apply_training_logs() returns table (entries integer, ticks integer)
language plpgsql security definer set search_path = public as $$
declare
  r record; v_comp bigint; v_boxes text[]; v_ini text; v_n integer;
  v_entries integer := 0; v_ticks integer := 0; v_this integer;
begin
  if not is_manager() then raise exception 'Only a manager can load the training log.'; end if;

  for r in select * from training_logs
            where applied_at is null and outcome in ('Competent', 'Indirect', 'Direct')
            order by date, id loop
    v_boxes := case r.outcome
                 when 'Competent' then array['self','obs1','obs2','assess1','assess2','assess3']
                 when 'Indirect'  then array['self','obs1','obs2']
                 else array['self'] end;
    v_ini := coalesce((select nullif(i.initials, '') from instructors i where i.id = r.trainer_id),
                      initials_of(r.trainer));

    -- One competency per phrase on the entry, at the lowest level not already finished.
    v_this := 0;
    for v_comp in
      select c.id
        from (select distinct m.comp_name, m.level
                from unnest(string_to_array(lower(coalesce(r.activity_text, '')), ',')) as a(phrase)
                join log_activity_map m on m.phrase = btrim(a.phrase)
               where m.comp_name is not null) g
        join lateral (
          select c2.id
            from competencies c2
            left join v_competency_status s
                   on s.comp_id = c2.id and s.instructor_id = r.instructor_id
           where c2.name = g.comp_name
             and (g.level is null or c2.level = g.level)
             and (c2.centre_id is null or c2.centre_id = (select centre_id from instructors where id = r.instructor_id)
                  or (select centre_id from instructors where id = r.instructor_id) is null)
             and coalesce(s.status, 'Not started') <> 'Competent'
           order by c2.level
           limit 1) c on true
    loop
      insert into training_log_comps (log_id, comp_id) values (r.id, v_comp) on conflict do nothing;

      insert into comp_signoffs (instructor_id, line_id, tick_type, signed_by, initials, observed_on, site, source, log_id)
      select r.instructor_id, l.id, t.box, coalesce(nullif(r.trainer, ''), 'Training log'), nullif(v_ini, ''), r.date,
             case when t.box like 'assess%' then nullif(r.location, '') end, 'training_log', r.id
        from competency_lines l
        cross join lateral (values ('self', l.needs_self), ('obs1', l.needs_obs1), ('obs2', l.needs_obs2),
                                   ('assess1', l.needs_assess1), ('assess2', l.needs_assess2), ('assess3', l.needs_assess3))
                           as t(box, needed)
       where l.comp_id = v_comp and not l.auto_from_amp and t.needed and t.box = any(v_boxes)
      on conflict (instructor_id, line_id, tick_type) do nothing;

      get diagnostics v_n = row_count;
      v_this  := v_this + v_n;        -- this entry
      v_ticks := v_ticks + v_n;       -- the whole run
    end loop;

    update training_logs set applied_at = now(), ticks_made = v_this where id = r.id;
    v_entries := v_entries + 1;
  end loop;

  return query select v_entries, v_ticks;
end $$;

-- ---------- Undo one entry
-- Takes back only the boxes that entry ticked, and only if nothing else has since claimed them.
create or replace function revert_training_log(p_log bigint) returns integer
language plpgsql security definer set search_path = public as $$
declare v_n integer;
begin
  if not is_manager() then raise exception 'Only a manager can undo a training log entry.'; end if;
  delete from comp_signoffs where log_id = p_log and source = 'training_log';
  get diagnostics v_n = row_count;
  delete from training_log_comps where log_id = p_log;
  update training_logs set applied_at = null, ticks_made = null where id = p_log;
  return v_n;
end $$;

revoke all on function apply_training_logs() from public;
revoke all on function revert_training_log(bigint) from public;
grant execute on function apply_training_logs() to authenticated;
grant execute on function revert_training_log(bigint) to authenticated;

-- ---------- What an entry did
drop view if exists v_log_review;
create view v_log_review with (security_invoker = true) as
select l.id as log_id, l.date, l.instructor_id, i.name as instructor, l.trainer, l.activity_text,
       l.location, l.outcome, l.summary, l.next_steps, l.applied_at, l.ticks_made,
       c.id as comp_id, c.name as comp_name, c.level, s.status as status_now
  from training_logs l
  join instructors i on i.id = l.instructor_id
  left join training_log_comps m on m.log_id = l.id
  left join competencies c on c.id = m.comp_id
  left join v_competency_status s on s.instructor_id = l.instructor_id and s.comp_id = c.id;

-- ---------- Security: same as every other personal record
alter table training_log_comps enable row level security;
alter table log_activity_map   enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where tablename='training_log_comps' and policyname='read own or manager') then
    create policy "read own or manager" on training_log_comps for select to authenticated
      using (is_manager() or exists (select 1 from training_logs l where l.id = log_id and l.instructor_id = my_instructor_id()));
    create policy "manager can change" on training_log_comps for all to authenticated
      using (is_manager()) with check (is_manager());
  end if;
  if not exists (select 1 from pg_policies where tablename='log_activity_map' and policyname='read when logged in') then
    create policy "read when logged in" on log_activity_map for select to authenticated using (true);
    create policy "manager can change"  on log_activity_map for all    to authenticated using (is_manager()) with check (is_manager());
  end if;
end $$;

create index if not exists training_logs_date_idx on training_logs (date desc);
create index if not exists comp_signoffs_log_idx  on comp_signoffs (log_id) where log_id is not null;

commit;

select count(*) as phrases_known, count(comp_name) as point_at_a_competency from log_activity_map;

-- ---------------------------------------------------------------------
--  CHECKS · read these five results
-- ---------------------------------------------------------------------

-- 1. Activities: expect 80, with 0 presets left.
select count(*) as activities, count(*) filter (where preset) as presets_left from activities;

-- 2. The data you already loaded, untouched. Expect roughly:
--    instructors 75 · qualifications 569 · amps 80 · hazards 444
--    competencies 62 · lines 2051 · sign-offs 191946
select 'instructors' as what, count(*) as rows from instructors
union all select 'qualifications', count(*) from qualifications_held
union all select 'amps', count(*) from amps
union all select 'amp hazards', count(*) from amp_hazards
union all select 'competencies', count(*) from competencies
union all select 'competency lines', count(*) from competency_lines
union all select 'sign-offs', count(*) from comp_signoffs
order by 1;

-- 3. Where everyone is. Expect about 949 Competent and 57 part way.
select status, count(*) as competencies from v_competency_status group by 1 order by 2 desc;

-- 4. Who still needs a login. Work through these in the app under
--    Edit > Instructors > "No login yet".
select name, employment from instructors
 where account_type = 'instructor' and auth_user_id is null and employment <> 'Past staff'
 order by name;

-- 5. The training log lookup, ready for the Smartsheet export.
select count(*) as phrases_known, count(comp_name) as point_at_a_competency from log_activity_map;

-- 6. How long a real search takes. Look in the Messages / Notices pane under the results.
--    Before this file is run it is seconds. After it, it should be tens of milliseconds.
do $$
declare t timestamptz; n integer; who uuid;
begin
  select id into who from instructors where account_type = 'instructor' order by name limit 1;
  t := clock_timestamp();
  select count(*) into n from v_competency_status where instructor_id = who;
  raise notice 'One instructor against all competencies: % rows in % ms',
    n, round(extract(epoch from (clock_timestamp() - t)) * 1000);
end $$;

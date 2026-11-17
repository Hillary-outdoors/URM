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

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

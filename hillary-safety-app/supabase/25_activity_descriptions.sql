-- URMA · step 25 · The activity descriptions the DM actually uses
--
-- "O'cave", "BB", "SOT Tokaanu" — what gets written on the day sheet. Each one is linked to the
-- AMP that covers it and the competency it needs, so picking the description is enough.
-- The AMP-shaped activities stay as they are; these sit alongside them and are marked as presets.
-- Safe to run again.

begin;

alter table activities add column if not exists preset boolean not null default false;

insert into activities (name, centre_id, call_in_type, in_national_park, preset, description)
select v.name, (select id from centres where name='Tongariro'), v.call_in, v.park::boolean, true, v.note
from (values
  ('O''cave','Cave','False','two AMPs share that number — picked the closest'),
  ('Bushcraft','None','False','two AMPs share that number — picked the closest'),
  ('SOT Tokaanu','Water','False',null),
  ('BB — Bush bashing','None','False','two AMPs share that number — picked the closest'),
  ('Tihia','None','False','two AMPs share that number — picked the closest'),
  ('FFX','None','False','You wrote AMP 3; the loaded one is AMP 4 ABL Flying Fox. AMP 3 here is Pool Tyrolean'),
  ('HR / High ropes','None','False',null),
  ('Pool T','None','False','two AMPs share that number — picked the closest / You wrote Comp: NA — no competency needed'),
  ('Indoor rock','None','False','two AMPs share that number — picked the closest / You wrote AMP 49; the loaded one is AMP 51 Rock Indoor Climbing Walls. Or High Ropes Course (L1) instead'),
  ('Canoe lake O-T','Water','False','You wrote L1 here and L2 on the water sheet — which?'),
  ('Raft build','Water','False',null),
  ('Mavericking (assist)','Water','False',null),
  ('Mavericking (trip lead)','Water','False',null),
  ('Tawhai falls','Water','True',null),
  ('Puke float','Water','False','Also needs Bush (L1) — two competencies · the second of the two'),
  ('Upper Mangatepopo (assist)','Water','True',null),
  ('Upper Mangatepopo (trip lead)','Water','True','Your note stops mid-line — is trip lead right?'),
  ('SOT lake T or O','Water','False',null),
  ('Canoe lake T or O','Water','False','You wrote L2 here and L1 on the other sheet'),
  ('Raft build lake T or O','Water','False','You wrote ''same as above'''),
  ('Sea kayak lake T or O','Water','False',null),
  ('SOT lake Taupo','Water','False',null),
  ('Canoe lake Taupo','Water','False',null),
  ('Sea kayak lake Taupo (sheltered water)','Water','False','You wrote ''Flat water sea kayak (L2)'''),
  ('Raft build Tokaanu','Water','False',null),
  ('Sea kayak Motuoapa','Water','False','You wrote the full L2 name')
) as v(name, call_in, park, note)
on conflict (name) do nothing;

update activities set preset = true where name in ('O''cave','Bushcraft','SOT Tokaanu','BB — Bush bashing','Tihia','FFX','HR / High ropes','Pool T','Indoor rock','Canoe lake O-T','Raft build','Mavericking (assist)','Mavericking (trip lead)','Tawhai falls','Puke float','Upper Mangatepopo (assist)','Upper Mangatepopo (trip lead)','SOT lake T or O','Canoe lake T or O','Raft build lake T or O','Sea kayak lake T or O','SOT lake Taupo','Canoe lake Taupo','Sea kayak lake Taupo (sheltered water)','Raft build Tokaanu','Sea kayak Motuoapa');

delete from activity_amps where act_id in (select id from activities where preset);
insert into activity_amps (act_id, amp_id)
select da.id, m.id
from (values
  ('O''cave','AMP 31 Cave Okupata Cave (Tongariro)'),
  ('Bushcraft','AMP 23 Bush craft (Tongariro)'),
  ('SOT Tokaanu','AMP 62 Water Lake Taupo Activities'),
  ('BB — Bush bashing','AMP 21 Bush Local Bush (Tongariro)'),
  ('Tihia','AMP 21 Bush Local Bush (Tongariro)'),
  ('FFX','AMP 4 ABL Flying Fox'),
  ('HR / High ropes','AMP 50 Rock High Ropes Course'),
  ('Pool T','AMP 82 Other Swimming Pool (Tongariro)'),
  ('Indoor rock','AMP 51 Rock Indoor Climbing Walls (Tongariro)'),
  ('Canoe lake O-T','AMP 61 Water Lake Otamangakau Water Activities'),
  ('Raft build','AMP 61 Water Lake Otamangakau Water Activities'),
  ('Mavericking (assist)','AMP 64 Tongariro River - SOT, Inflatable'),
  ('Mavericking (trip lead)','AMP 64 Tongariro River - SOT, Inflatable'),
  ('Tawhai falls','AMP 71 Water Tawhai Falls Jump'),
  ('Puke float','AMP 75 Water Pukehinau Stream Travel'),
  ('Upper Mangatepopo (assist)','AMP 77 Water Upper Mangatepopo Steep Creek Trip'),
  ('Upper Mangatepopo (trip lead)','AMP 77 Water Upper Mangatepopo Steep Creek Trip'),
  ('SOT lake T or O','AMP 61 Water Lake Otamangakau Water Activities'),
  ('Canoe lake T or O','AMP 61 Water Lake Otamangakau Water Activities'),
  ('Raft build lake T or O','AMP 61 Water Lake Otamangakau Water Activities'),
  ('Sea kayak lake T or O','AMP 61 Water Lake Otamangakau Water Activities'),
  ('SOT lake Taupo','AMP 62 Water Lake Taupo Activities'),
  ('Canoe lake Taupo','AMP 62 Water Lake Taupo Activities'),
  ('Sea kayak lake Taupo (sheltered water)','AMP 62 Water Lake Taupo Activities'),
  ('Raft build Tokaanu','AMP 62 Water Lake Taupo Activities'),
  ('Sea kayak Motuoapa','AMP 62 Water Lake Taupo Activities')
) as v(descr, ampact)
join activities da on da.name = v.descr
join activities aa on aa.name = v.ampact
join amps m on m.act_id = aa.id
on conflict do nothing;

delete from activity_comps where act_id in (select id from activities where preset);
insert into activity_comps (act_id, comp_id, role, qualifier)
select da.id, c.id, 'Instructor', v.qual
from (values
  ('O''cave','TL1-35',null),
  ('Bushcraft','TL1-14',null),
  ('SOT Tokaanu','TL1-28','Sit-on'),
  ('BB — Bush bashing','TL1-14',null),
  ('Tihia','TL1-14',null),
  ('FFX','TL1-39',null),
  ('HR / High ropes','TL1-37',null),
  ('Indoor rock','TL1-25',null),
  ('Canoe lake O-T','TL1-28','Canoe'),
  ('Raft build','TL1-28','Sit-on'),
  ('Mavericking (assist)','TL1-33',null),
  ('Mavericking (trip lead)','TL2-25',null),
  ('Tawhai falls','TL1-31','Tawhai endorsement'),
  ('Puke float','TL1-31',null),
  ('Puke float','TL1-14',null),
  ('Upper Mangatepopo (assist)','TL2-28',null),
  ('Upper Mangatepopo (trip lead)','TL3-03',null),
  ('SOT lake T or O','TL1-28','Sit-on'),
  ('Canoe lake T or O','TL2-23','Canoe'),
  ('Raft build lake T or O','TL2-23','Canoe'),
  ('Sea kayak lake T or O','TL1-28','Sea kayak'),
  ('SOT lake Taupo','TL1-28','Sit-on'),
  ('Canoe lake Taupo','TL1-28','Canoe'),
  ('Sea kayak lake Taupo (sheltered water)','TL2-23','Sea kayak'),
  ('Raft build Tokaanu','TL1-28',null),
  ('Sea kayak Motuoapa','TL2-23','Sea kayak')
) as v(descr, code, qual)
join activities da on da.name = v.descr
join competencies c on c.code = v.code
on conflict do nothing;

commit;

-- what landed:
select a.name as description, a.call_in_type,
       (select string_agg(m.title, ' + ') from activity_amps x join amps m on m.id = x.amp_id where x.act_id = a.id) as amps,
       (select string_agg(c.name || ' (L' || c.level || ')' || coalesce(' — ' || r.qualifier, ''), ' + ')
          from activity_comps r join competencies c on c.id = r.comp_id where r.act_id = a.id) as competencies
from activities a where a.preset order by a.name;

-- URMA · step 31 · What each centre's day sheet needs
--
-- Tongariro has no tides and does not want a sunset box; Coromandel has no alpine and no avalanche
-- rating. Rather than writing either of those into the app, each centre says what its day sheet
-- carries, and the screen follows.
--
-- Weather watches and warnings, river levels and closures apply to both centres and always have.
--
-- Safe to run again.

begin;

alter table centres add column if not exists coastal boolean not null default false;
alter table centres add column if not exists alpine  boolean not null default false;

update centres set coastal = true  where name ilike '%coromandel%';
update centres set alpine  = true  where name ilike '%tongariro%';
update centres set coastal = false where name ilike '%tongariro%';
update centres set alpine  = false where name ilike '%coromandel%';

-- Tides and sunset belong to the coast, so clear anything that was typed into the
-- Tongariro boxes before they disappeared from that screen.
update dm_day_logs d set tide_notes = null, sunset = null
  from centres c
 where c.id = d.centre_id and not c.coastal
   and (d.tide_notes is not null or d.sunset is not null);

commit;

select name, coastal as shows_tides_and_sunset, alpine as shows_avalanche from centres order by id;

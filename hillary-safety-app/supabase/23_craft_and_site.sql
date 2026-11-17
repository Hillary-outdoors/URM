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

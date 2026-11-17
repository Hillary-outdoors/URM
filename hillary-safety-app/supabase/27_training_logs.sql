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
  ('other',            null, null, 'training, not a competency')
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

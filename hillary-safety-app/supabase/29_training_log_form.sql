-- URMA · step 29 · The training log, filled in inside the app
--
-- The Smartsheet import is out. Instead the log is a form in the app, open to every instructor,
-- who can fill one in for themselves or for anyone else. It is honesty-based: managers do a
-- compliance check every few months rather than the app policing who may write what.
--
-- The one thing the app records on its own is who was signed in when the entry was written
-- (filled_by). Nobody types it and nobody can change it. A compliance check can then see at a
-- glance whether an entry was written by the trainer named on it or by the trainee.
--
-- The form names the competency being observed or assessed, so nothing has to be guessed from the
-- activity any more. Saving an entry ticks the boxes for the competencies it names, at the level it
-- names, exactly as before: Competent ticks every box, Indirect the Self and Observation boxes,
-- Direct the Self box. Adding only, never removing, and every entry still has an Undo.
--
-- Safe to run again.

begin;

-- ---------- The rest of the paper form
alter table training_logs add column if not exists filled_by          uuid references instructors(id) on delete set null;
alter table training_logs add column if not exists created_at         timestamptz not null default now();
alter table training_logs add column if not exists session_objectives text;
alter table training_logs add column if not exists self_observation   text;
alter table training_logs add column if not exists sms_comments       text;
alter table training_logs add column if not exists students_aware     text;
alter table training_logs add column if not exists linked_to_frame    text;
alter table training_logs add column if not exists client_group       text;
alter table training_logs add column if not exists training_context   text;
alter table training_logs add column if not exists dev_needs          text;
alter table training_logs add column if not exists feedback_given     text;
alter table training_logs add column if not exists outcome_comments   text;

-- The eight things the form scores out of five, each with room for a comment.
do $$
declare k text;
begin
  foreach k in array array['quality','planning','brief','education','wellbeing','cultural','group_mgmt','skills','debrief']
  loop
    execute format('alter table training_logs add column if not exists score_%s smallint', k);
    execute format('alter table training_logs add column if not exists notes_%s text', k);
    execute format('alter table training_logs drop constraint if exists training_logs_score_%s_range', k);
    execute format('alter table training_logs add constraint training_logs_score_%s_range check (score_%s is null or score_%s between 1 and 5)', k, k, k);
  end loop;
end $$;

-- Entries written in the app have no Smartsheet row and no dedupe key, so the unique indexes
-- must tolerate that. A plain unique index already allows any number of empty values.
create index if not exists training_logs_filled_by_idx on training_logs (filled_by);
create index if not exists training_logs_trainer_idx   on training_logs (trainer_id);

-- ---------- Any instructor may write one, for anyone
alter table training_logs enable row level security;
do $$
begin
  -- start clean so this file can be run again
  drop policy if exists "read own or manager"     on training_logs;
  drop policy if exists "instructors can write"   on training_logs;
  drop policy if exists "manager can change"      on training_logs;
  drop policy if exists "author or manager edits"  on training_logs;

  -- Everyone signed in can read the log. It is a training record, not a personnel file, and
  -- instructors need to see what has been written about them and by them.
  create policy "read own or manager" on training_logs for select to authenticated using (true);

  -- Anyone signed in can add an entry, about anyone — but only ever in their own name.
  create policy "instructors can write" on training_logs for insert to authenticated
    with check (filled_by = my_instructor_id());

  -- The person who wrote it can correct it; a manager can correct anything.
  create policy "author or manager edits" on training_logs for update to authenticated
    using (is_manager() or filled_by = my_instructor_id())
    with check (is_manager() or filled_by = my_instructor_id());

  -- Only a manager deletes.
  create policy "manager can change" on training_logs for delete to authenticated using (is_manager());

  drop policy if exists "read own or manager" on training_log_comps;
  drop policy if exists "manager can change"  on training_log_comps;
  create policy "read own or manager" on training_log_comps for select to authenticated using (true);
  create policy "manager can change" on training_log_comps for all to authenticated
    using (is_manager() or exists (select 1 from training_logs l where l.id = log_id and l.filled_by = my_instructor_id()))
    with check (is_manager() or exists (select 1 from training_logs l where l.id = log_id and l.filled_by = my_instructor_id()));
end $$;

-- ---------- Saving an entry ticks its boxes
-- Where the form named the competencies, use those. Where an older entry came from Smartsheet with
-- nothing but an activity, fall back to the phrase lookup as before.
create or replace function apply_training_logs() returns table (entries integer, ticks integer)
language plpgsql security definer set search_path = public as $$
declare
  r record; v_comp bigint; v_boxes text[]; v_ini text; v_n integer;
  v_entries integer := 0; v_ticks integer := 0; v_this integer; v_named boolean;
begin
  if not is_manager() and my_instructor_id() is null then
    raise exception 'You must be signed in to save a training log entry.';
  end if;

  for r in select * from training_logs
            where applied_at is null and outcome in ('Competent', 'Indirect', 'Direct')
            order by date, id loop
    v_boxes := case r.outcome
                 when 'Competent' then array['self','obs1','obs2','assess1','assess2','assess3']
                 when 'Indirect'  then array['self','obs1','obs2']
                 else array['self'] end;
    v_ini := coalesce((select nullif(i.initials, '') from instructors i where i.id = r.trainer_id),
                      initials_of(r.trainer));
    v_this := 0;
    v_named := exists (select 1 from training_log_comps m where m.log_id = r.id);

    for v_comp in
      -- the competencies the form named, exactly as named
      select m.comp_id from training_log_comps m where m.log_id = r.id and v_named
      union all
      -- or, for an old Smartsheet entry, worked out from the activity
      select c.id
        from (select distinct m.comp_name, m.level
                from unnest(string_to_array(lower(coalesce(r.activity_text, '')), ',')) as a(phrase)
                join log_activity_map m on m.phrase = btrim(a.phrase)
               where m.comp_name is not null and not v_named) g
        join lateral (
          select c2.id
            from competencies c2
            left join comp_status s on s.comp_id = c2.id and s.instructor_id = r.instructor_id
           where c2.name = g.comp_name
             and (g.level is null or c2.level = g.level)
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
      v_this  := v_this + v_n;
      v_ticks := v_ticks + v_n;
    end loop;

    update training_logs set applied_at = now(), ticks_made = v_this where id = r.id;
    v_entries := v_entries + 1;
  end loop;

  return query select v_entries, v_ticks;
end $$;

-- An instructor saving their own entry needs to be able to run this for that entry alone.
create or replace function apply_one_training_log(p_log bigint) returns integer
language plpgsql security definer set search_path = public as $$
declare v_before integer; v_after integer;
begin
  if my_instructor_id() is null and not is_manager() then
    raise exception 'You must be signed in.';
  end if;
  if not exists (select 1 from training_logs where id = p_log
                  and (is_manager() or filled_by = my_instructor_id())) then
    raise exception 'That entry is not yours to apply.';
  end if;
  select count(*) into v_before from comp_signoffs where log_id = p_log;
  -- reuse the same rules by applying everything outstanding for this one entry
  update training_logs set applied_at = null where id = p_log and applied_at is null;
  perform apply_training_logs();
  select count(*) into v_after from comp_signoffs where log_id = p_log;
  return v_after - v_before;
end $$;

-- The author of an entry can undo it as well as a manager, so a mistake can be fixed on the spot.
create or replace function revert_training_log(p_log bigint) returns integer
language plpgsql security definer set search_path = public as $$
declare v_n integer;
begin
  if not exists (select 1 from training_logs where id = p_log
                  and (is_manager() or filled_by = my_instructor_id())) then
    raise exception 'That entry is not yours to undo.';
  end if;
  delete from comp_signoffs where log_id = p_log and source = 'training_log';
  get diagnostics v_n = row_count;
  delete from training_log_comps where log_id = p_log;
  update training_logs set applied_at = null, ticks_made = null where id = p_log;
  return v_n;
end $$;

grant execute on function apply_training_logs(), apply_one_training_log(bigint), revert_training_log(bigint) to authenticated;

-- ---------- One flat row per entry, for the audit export
create or replace view v_training_log_export with (security_invoker = true) as
select l.date, c.name as centre, l.trainer, i.name as trainee,
       w.name as written_by,
       case when l.filled_by is not null and l.filled_by = l.instructor_id
            then 'written by the trainee' else '' end as compliance_note,
       l.days, l.activity_text as activity, l.location,
       (select string_agg(cp.name || ' L' || cp.level, ' + ' order by cp.level, cp.name)
          from training_log_comps m join competencies cp on cp.id = m.comp_id
         where m.log_id = l.id)                                as competencies,
       l.training_type, l.session_type, l.outcome, l.outcome_comments,
       l.session_objectives, l.summary, l.self_observation,
       l.sms_ok, l.sms_comments, l.students_aware, l.linked_to_frame,
       l.client_group, l.training_context,
       l.score_quality, l.notes_quality, l.score_planning, l.notes_planning,
       l.score_brief, l.notes_brief, l.score_education, l.notes_education,
       l.score_wellbeing, l.notes_wellbeing, l.score_cultural, l.notes_cultural,
       l.score_group_mgmt, l.notes_group_mgmt, l.score_skills, l.notes_skills,
       l.score_debrief, l.notes_debrief,
       l.dev_needs, l.feedback_given, l.next_steps, l.folder_updated,
       l.ticks_made as boxes_ticked, l.applied_at, l.created_at, l.id as entry_id
  from training_logs l
  join instructors i on i.id = l.instructor_id
  left join instructors w on w.id = l.filled_by
  left join centres c on c.id = l.centre_id;

grant select on v_training_log_export to authenticated;
revoke all on v_training_log_export from anon;

commit;

select count(*) as log_entries, count(filled_by) as written_in_the_app from training_logs;

-- =====================================================================
-- FILE 2 of 4: SECURITY
-- Run after file 1. This is what keeps the data safe. The rules live in
-- the database itself, so they hold no matter what the app does.
--
-- Two kinds of login:
--   instructor : sees their own records. Can tick only their own Self boxes.
--   manager    : sees and edits everything.
-- Someone who is not logged in sees nothing at all.
-- =====================================================================

-- Helper: which instructors row belongs to the person logged in?
create or replace function my_instructor_id() returns uuid
language sql stable security definer set search_path = public as $$
  select id from instructors where auth_user_id = auth.uid()
$$;

-- Helper: is the person logged in using a manager account?
create or replace function is_manager() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from instructors
                 where auth_user_id = auth.uid() and account_type = 'manager')
$$;

-- Helper: is the person logged in on this intention (or did they send it)?
create or replace function is_on_intention(p_intention bigint) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from intentions i
                 where i.id = p_intention and i.submitted_by = my_instructor_id())
      or exists (select 1 from intention_instructors ii
                 where ii.intention_id = p_intention and ii.instructor_id = my_instructor_id())
$$;

-- Switch row-level security on for every table.
alter table centres               enable row level security;
alter table instructors           enable row level security;
alter table qualifications_held   enable row level security;
alter table activities            enable row level security;
alter table amps                  enable row level security;
alter table amp_hazards           enable row level security;
alter table amp_acknowledgements  enable row level security;
alter table competencies          enable row level security;
alter table competency_lines      enable row level security;
alter table training_logs         enable row level security;
alter table comp_signoffs         enable row level security;
alter table dm_day_logs           enable row level security;
alter table intentions            enable row level security;
alter table intention_instructors enable row level security;
alter table intention_activities  enable row level security;
alter table comms_log             enable row level security;
alter table change_log            enable row level security;

-- People who are not logged in get nothing, full stop.
revoke all on all tables    in schema public from anon;
revoke all on all sequences in schema public from anon;

-- ---------- Reference material: everyone logged in can read, only a manager can change
do $$
declare t text;
begin
  foreach t in array array['centres','instructors','activities','amps','amp_hazards','competencies','competency_lines'] loop
    execute format('create policy "read when logged in" on %I for select to authenticated using (true)', t);
    execute format('create policy "manager can change"  on %I for all    to authenticated using (is_manager()) with check (is_manager())', t);
  end loop;
end $$;

-- ---------- Personal records: you see your own, a manager sees all, only a manager changes them
do $$
declare t text;
begin
  foreach t in array array['qualifications_held','training_logs','amp_acknowledgements'] loop
    execute format('create policy "read own or manager" on %I for select to authenticated using (is_manager() or instructor_id = my_instructor_id())', t);
    execute format('create policy "manager can change"  on %I for all    to authenticated using (is_manager()) with check (is_manager())', t);
  end loop;
end $$;
-- (Instructors sign an AMP through the acknowledge_amp function in file 3,
--  which always records the current version, so a signature cannot be faked.)

-- ---------- Competency ticks
create policy "read own or manager" on comp_signoffs for select to authenticated
  using (is_manager() or instructor_id = my_instructor_id());
create policy "manager can change" on comp_signoffs for all to authenticated
  using (is_manager()) with check (is_manager());
-- An instructor may add or remove ONLY their own Self ticks.
create policy "instructor adds own self tick" on comp_signoffs for insert to authenticated
  with check (instructor_id = my_instructor_id() and tick_type = 'self' and source = 'self');
create policy "instructor removes own self tick" on comp_signoffs for delete to authenticated
  using (instructor_id = my_instructor_id() and tick_type = 'self');

-- ---------- Intentions: you see the ones you are on, a manager sees all
create policy "read own or manager" on intentions for select to authenticated
  using (is_manager() or is_on_intention(id));
create policy "manager can change" on intentions for all to authenticated
  using (is_manager()) with check (is_manager());

create policy "read own or manager" on intention_instructors for select to authenticated
  using (is_manager() or is_on_intention(intention_id));
create policy "manager can change" on intention_instructors for all to authenticated
  using (is_manager()) with check (is_manager());

create policy "read own or manager" on intention_activities for select to authenticated
  using (is_manager() or is_on_intention(intention_id));
create policy "manager can change" on intention_activities for all to authenticated
  using (is_manager()) with check (is_manager());
-- (Instructors send an intention and call in safe through functions in file 3.)

-- ---------- Manager-only records
do $$
declare t text;
begin
  foreach t in array array['dm_day_logs','comms_log'] loop
    execute format('create policy "manager only" on %I for all to authenticated using (is_manager()) with check (is_manager())', t);
  end loop;
end $$;

-- The change log can be read and added to by a manager, but never edited or deleted.
create policy "manager reads" on change_log for select to authenticated using (is_manager());
create policy "manager adds"  on change_log for insert to authenticated with check (is_manager());

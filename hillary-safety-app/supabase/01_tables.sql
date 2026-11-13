-- =====================================================================
-- Hillary Outdoors Safety System
-- FILE 1 of 4: TABLES
-- Run this first, in the Supabase SQL Editor, on a brand-new project.
-- It only creates empty tables. It is safe to read top to bottom:
-- each table has a one-line note saying what one row means.
-- =====================================================================

-- One row per site.
create table centres (
  id   smallint generated always as identity primary key,
  name text not null unique
);

-- One row per person who can log in (instructors and the manager account).
create table instructors (
  id            uuid primary key default gen_random_uuid(),
  auth_user_id  uuid unique references auth.users(id) on delete set null,
  name          text not null,
  initials      text,
  centre_id     smallint references centres(id),
  account_type  text not null default 'instructor' check (account_type in ('instructor','manager')),
  employment    text not null default 'Staff' check (employment in ('Staff','Contractor','Past staff')),
  start_date    date,
  end_date      date,
  created_at    timestamptz not null default now()
);

-- One row per outside qualification a person holds (for example NZOIA Alpine 1).
create table qualifications_held (
  id            bigint generated always as identity primary key,
  instructor_id uuid not null references instructors(id) on delete cascade,
  qualification text not null,
  awarded_on    date,
  expires_on    date,
  checked_by    text
);

-- One row per activity.
create table activities (
  id               bigint generated always as identity primary key,
  name             text not null unique,
  centre_id        smallint references centres(id),
  call_in_type     text not null default 'None' check (call_in_type in ('None','Cave','Water','Mountain')),
  in_national_park boolean not null default false,
  active           boolean not null default true
);

-- One row per Activity Management Plan. Every box on the paper AMP is a column.
create table amps (
  id                      bigint generated always as identity primary key,
  act_id                  bigint not null unique references activities(id) on delete cascade,
  folder                  text,
  activity_number         text,
  title                   text not null,
  activity_description    text,
  location                text,
  camping                 text,
  toilets                 text,
  water                   text,
  emergency_response      text,
  access_permission       text,
  instructor_requirements text,
  client_competencies     text,
  specific_equipment      text,
  specific_policies       text,
  other_resources         text,
  key_hazards             text,
  previous_incidents      text,
  version                 integer not null default 0,   -- 0 = not published yet
  change_summary          text,
  updated_by              text,
  updated_at              timestamptz not null default now()
);

-- One row per line of the Safety Management table at the bottom of an AMP.
create table amp_hazards (
  id                  bigint generated always as identity primary key,
  amp_id              bigint not null references amps(id) on delete cascade,
  sort_order          integer not null default 0,
  control             text,
  activity_part       text,
  hazard              text,
  management_strategy text
);

-- One row each time a person signs an AMP. Old signatures are kept.
create table amp_acknowledgements (
  id            bigint generated always as identity primary key,
  instructor_id uuid not null references instructors(id) on delete cascade,
  amp_id        bigint not null references amps(id) on delete cascade,
  amp_version   integer not null,
  signed_at     timestamptz not null default now(),
  unique (instructor_id, amp_id, amp_version)
);

-- One row per competency page (for example Alpine Summer L1).
create table competencies (
  id             bigint generated always as identity primary key,
  name           text not null,
  level          smallint not null default 1 check (level between 1 and 4),
  act_id         bigint references activities(id) on delete set null,
  centre_id      smallint references centres(id),
  version        text,
  scope          text,
  prerequisites  text,
  assessment     text,
  rcc_rule       text,
  sites_required smallint not null default 1
);

-- One row per line inside a competency (the 500 to 700 lines).
create table competency_lines (
  id            bigint generated always as identity primary key,
  comp_id       bigint not null references competencies(id) on delete cascade,
  section       text not null default 'Technical Competence',
  element       text not null default '',
  content       text not null,
  sort_order    integer not null default 0,
  needs_self    boolean not null default true,
  needs_obs1    boolean not null default true,
  needs_assess1 boolean not null default true,
  needs_assess2 boolean not null default false,
  essential     boolean not null default true,
  auto_from_amp boolean not null default false   -- ticks itself when the AMP is acknowledged
);

-- One row per training session per trainee. Smartsheet rows will land here later.
create table training_logs (
  id             bigint generated always as identity primary key,
  date           date not null,
  trainer        text,
  instructor_id  uuid not null references instructors(id) on delete cascade,
  act_id         bigint references activities(id) on delete set null,
  outcome        text,
  notes          text,
  source         text not null default 'app' check (source in ('app','smartsheet')),
  smartsheet_row bigint unique,
  created_at     timestamptz not null default now()
);

-- One row per tick in someone's competency folder. No row = empty box.
create table comp_signoffs (
  id            bigint generated always as identity primary key,
  instructor_id uuid not null references instructors(id) on delete cascade,
  line_id       bigint not null references competency_lines(id) on delete cascade,
  tick_type     text not null check (tick_type in ('self','obs1','assess1','assess2')),
  site          text,
  signed_by     text,
  observed_on   date,
  source        text not null default 'manual' check (source in ('self','manual','training_log','override')),
  log_id        bigint references training_logs(id) on delete set null,
  reason        text,
  created_at    timestamptz not null default now(),
  unique (instructor_id, line_id, tick_type),
  -- every tick that is not a self tick must say who signed it and why
  check (tick_type = 'self' or (signed_by is not null and (source = 'training_log' or reason is not null)))
);

-- One row per centre per day: the printed box at the top of the DM notebook page.
create table dm_day_logs (
  id            bigint generated always as identity primary key,
  date          date not null,
  centre_id     smallint not null references centres(id),
  dm_name       text,
  wx_state      text check (wx_state in ('Green','Yellow','Red')),
  wx_events     text check (wx_events in ('None','Watch','Warning')),
  avalanche     text check (avalanche in ('Nil','Green','Yellow','Orange','Red','Black')),
  closures      text,
  wx_notes      text,
  river_levels  text,
  dm_judgements text,
  unique (date, centre_id)
);

-- One row per plan for the day.
create table intentions (
  id             bigint generated always as identity primary key,
  centre_id      smallint not null references centres(id),
  date           date not null,
  group_name     text,
  pax            integer,
  outcome_of_day text,
  plan           text,
  overnight      boolean not null default false,
  due_by         time,          -- only for call-in activities
  started_at     time,          -- logged by the DM when the instructor calls
  called_in_at   time,
  called_in_as   text,
  status         text not null default 'Waiting' check (status in ('Waiting','Approved','Closed')),
  briefed        boolean not null default false,
  dm_notes       text,
  debrief_notes  text,
  entered_late   boolean not null default false,
  submitted_by   uuid references instructors(id) on delete set null,
  created_at     timestamptz not null default now()
);

-- One row per instructor on an intention.
create table intention_instructors (
  intention_id  bigint not null references intentions(id) on delete cascade,
  instructor_id uuid   not null references instructors(id) on delete cascade,
  primary key (intention_id, instructor_id)
);

-- One row per activity on an intention.
create table intention_activities (
  intention_id bigint not null references intentions(id) on delete cascade,
  act_id       bigint not null references activities(id) on delete cascade,
  primary key (intention_id, act_id)
);

-- One row per timed radio call or note in the DM's running log.
create table comms_log (
  id            bigint generated always as identity primary key,
  date          date not null,
  centre_id     smallint not null references centres(id),
  time          time not null,
  instructor_id uuid references instructors(id) on delete set null,
  intention_id  bigint references intentions(id) on delete set null,
  entry         text not null,
  created_at    timestamptz not null default now()
);

-- One row per manual sign-off edit or AMP version. Never edited, only added to.
create table change_log (
  id         bigint generated always as identity primary key,
  changed_at timestamptz not null default now(),
  changed_by text,
  kind       text not null check (kind in ('Sign-off','AMP','Instructor')),
  what       text not null,
  reason     text
);

-- Indexes: these just make common look-ups fast.
create index on comp_signoffs (instructor_id);
create index on competency_lines (comp_id, sort_order);
create index on amp_acknowledgements (amp_id, instructor_id);
create index on intentions (date, centre_id);
create index on intentions (status);
create index on intention_instructors (instructor_id);
create index on comms_log (date, centre_id);
create index on training_logs (instructor_id);

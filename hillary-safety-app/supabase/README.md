# URMA · the SQL files

## Tomorrow, run one file

**`URMA_run_this_one_file.sql`** — paste the whole thing into
Supabase › SQL Editor › New query and press Run. It is everything
outstanding, in the right order, and it is safe to run twice.

It prints five checks at the bottom. The one to act on is the fourth:
the people who still have no login.

## The rest of the folder

These are the history — what has already been run, kept so the database
can be rebuilt from nothing if it ever has to be. You do not need to run
them again.

| File | What it did |
| --- | --- |
| `00_check` – `06_day_board` | Tables, security, views, the day board |
| `07_six_boxes` | The six tick boxes and the names printed on each form |
| `09`, `10`, `11`, `12` | Requirements, 74 people, 80 activities and AMPs, 444 hazards |
| `13`, `14a/b/c` | 62 competencies and their 2,051 lines |
| `16_rrcc_signoffs` | The Recognition of Current Competence boxes |
| `17_matrix_backfill` | The competency matrix, which is the source of truth |
| `18`, `21`, `22`, `23`, `24`, `26`, `27` | Now bundled into `URMA_run_this_one_file.sql` |
| `19_link_logins` | Matched names to logins that already existed. Superseded: logins are now made in the app, under Edit › Instructors |
| `OPTIONAL_15_ticks_from_folders` | The ticks read off the folder scans. **Not loaded.** Reading them was 89% accurate, which is not good enough to put a tick against someone's name. Left here in case you ever want it |

## Rebuilding from scratch

In order: `01`, `02`, `03`, `04`, `06`, `07`, `09`, `10`, `11`, `12`,
`13`, `14a`, `14b`, `14c`, `16`, `17`, then `URMA_run_this_one_file.sql`.

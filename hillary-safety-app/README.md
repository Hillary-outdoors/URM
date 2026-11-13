# Hillary Outdoors Safety System

A web app for intentions, competencies and Activity Management Plans (AMPs).

- **Instructors** (phone): send an intention, call in safe, read and sign AMPs, tick their own Self boxes, keep a logbook.
- **Managers** (laptop or phone): day sheet, open intentions with overdue alerts, comms log, sign-offs, AMP and competency editing, instructor logins, exports for audits and DOC.

## Start here

| I want to… | Read |
|---|---|
| Set the system up from nothing | [docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md) |
| Understand how it is kept safe and backed up | [docs/SECURITY_AND_BACKUPS.md](docs/SECURITY_AND_BACKUPS.md) |
| See what each database table is for | the comments in [supabase/01_tables.sql](supabase/01_tables.sql) |

## What is in this folder

| Folder or file | What it is |
|---|---|
| `supabase/` | Five SQL files that build the database. Run once, in order, in Supabase. |
| `app/` | The screens: `login`, `instructor`, `manager`, and one server API (`api/instructors`). |
| `components/` | The building blocks of the screens. `components/manager/` has one file per manager tab. |
| `lib/` | The Supabase connection and shared helpers (dates, overdue rules, exports). |
| `docs/` | The setup guide and the security and backups guide. |
| `.env.example` | The three settings the app needs. The real values go in Vercel, never in GitHub. |

## The three services

| Service | Job |
|---|---|
| **Supabase** | Holds the database and the logins. All security rules live here. |
| **GitHub** | Holds this code. |
| **Vercel** | Turns the code into the live website. Rebuilds whenever GitHub changes. |

## Rules the system applies

- Only cave, water, mountain and overnight activities are timed and called in.
- An intention stays open until someone calls in safe.
- Yellow alert at 10 minutes past the due time, red at 20.
- Competency status is worked out from ticks: Direct once started, Indirect when every required Self and Obs 1 tick is done, Competent when every required tick is done.
- Instructors can tick only their own Self boxes. Everything else is a manager sign-off with a name and a reason.
- A new AMP version asks every instructor to sign again.

## Not built yet

- Smartsheet training-log link. The `training_logs` table is ready for it.
- Importing AMPs or competencies from Word files.
- Incident reporting.
- Notifications when the app is closed. Alerts need the manager page open on a device.

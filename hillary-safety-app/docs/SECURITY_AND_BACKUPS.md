# Security and backups

This explains how the system is protected, what you must do yourself, and how to get the data back if something goes wrong.

## How well tested is this?

Be clear-eyed about this before relying on it.

- **The database rules were tested** on a local copy of the database, signed in as a manager, an instructor and a logged-out visitor. All 26 checks passed, including that an instructor cannot tick anything but their own Self boxes, cannot see other people's records, and cannot make themselves a manager.
- **The screens were tested** by clicking through every tab against a stand-in for the database.
- **The whole system has not yet been run against a real Supabase project.** Expect to find some faults in the first real run. Run a pretend day with test data before entering real records, and before anyone depends on the overdue alerts.

## What is built in

| Protection | What it means |
|---|---|
| Rules live in the database | Who can see or change each row is enforced by Supabase itself (`supabase/02_security.sql`). Even someone who bypassed the app would hit the same rules. |
| Nothing without a login | A person who is not signed in can read nothing. |
| Two account types only | Instructors see their own records. The manager account sees everything. |
| Instructors cannot sign themselves off | They can add or remove only their own Self ticks. Every other tick needs the manager account, a name and a reason. |
| AMP signatures cannot be faked | Signing goes through one database function that always records the current version. |
| The change log cannot be edited | Rows can be added but never changed or deleted through the app. |
| No public sign-up | Logins are created only by a manager (once you complete Step 3 of the setup guide). |
| The secret key stays on the server | It is used in one file, `app/api/instructors/route.ts`, and is never sent to a browser. |
| Past staff are locked out | Marking someone as Past staff switches off their login and keeps all their records. |
| Hardened web settings | The site cannot be embedded in another site, is HTTPS-only, and asks search engines not to index it. |
| Current software | The app was built on supported versions with no known vulnerabilities reported at build time. |

## The shared manager login: know the trade-off

The system has one manager login that several people use. Because of that, the database cannot tell which manager did something. The app covers this by asking for a typed name on the day sheet, on every sign-off and on every AMP publish, and that typed name is what the change log records.

This relies on people typing their own name. If you later need proof of who did what, give each manager their own login: create the user in Supabase and run file 5 again with their email. Nothing else needs to change.

## What you must do

1. **Use organisation-owned accounts** for Supabase, GitHub and Vercel, with at least two people able to get in.
2. **Turn on two-step sign-in** on all three of those accounts.
3. **Use a long, unique manager password** and change it whenever someone who knew it leaves.
4. **Keep the GitHub repository private.**
5. **Never put the secret key anywhere except Vercel.** If it is ever exposed, open Supabase → Project Settings → API Keys, create a new secret key, put it in Vercel, redeploy, then delete the old one.
6. **Mark leavers as Past staff** on the day they leave.
7. **Use lock screens** on the duty laptop and on phones that stay signed in.

## Personal information

The system holds staff names, qualifications, competency records and movements. That is personal information. The database is hosted outside New Zealand (for example in Sydney). Check with whoever handles privacy for the organisation that this fits its obligations, and tell staff what is recorded and why. This guide is not legal advice.

## Backups

### What you get from Supabase

| Supabase plan | Automatic backups |
|---|---|
| Free | None |
| Pro | Daily, kept for 7 days |
| Pro with the point-in-time add-on | Restore to any moment, at extra cost |

Check Supabase's pricing page for current terms. On the Free plan the only backups are the ones you make yourself.

### What to do

| How often | Action |
|---|---|
| Daily (automatic) | Be on the Pro plan so Supabase takes a daily backup. |
| Weekly | Manager → **Export → Export everything**. Save the files to the organisation's shared drive in a dated folder. |
| Before any big change | Run **Export everything** first. |
| Twice a year | Practise a restore (below) so you know it works. |

The weekly export matters even on the Pro plan. It is a copy you hold yourself, in a format anyone can open in Excel, and it still exists if the Supabase account is lost.

**What the export does not include:** the login accounts themselves (emails and passwords), and competency and AMP wording. Those are covered by the Supabase backup. The export covers the records: intentions, day sheets, comms, sign-offs, statuses, acknowledgements, the change log and the instructor list.

### Restoring

**If data was deleted or damaged recently (Pro plan):**
1. Open Supabase → **Database → Backups**.
2. Pick the most recent backup from before the problem.
3. Restore. The project is unavailable for a short while.
4. Everything entered after that backup is lost. Re-enter it from paper or from memory.

**If the whole Supabase project is lost:**
1. Follow the setup guide from Step 1 to make a new project and database.
2. Put the new URL and keys into Vercel and redeploy.
3. Re-create logins under Edit → Instructors.
4. Re-enter AMPs and competencies. Use the exported spreadsheets as the reference for sign-offs.

This second case is slow, which is why the daily Supabase backup is the main protection and the weekly export is the fallback.

**If the website is down but the data is fine:** open Vercel → Deployments and promote the last working deployment.

**If the app is unreachable during a working day:** go back to the paper notebook for intentions and call-ins. The next day, use **Add intention** with yesterday's date to enter them. They are saved to history marked "Entered later".

## Keeping it alive

| When | Task |
|---|---|
| Monthly | Sign in to Supabase, GitHub and Vercel. Read any warning emails or banners. |
| Every 6 months | Update the software versions in `package.json` and check the app still builds. This needs someone comfortable with code. |
| When Supabase announces a change to API keys | Follow their migration note. This app already uses the newer publishable and secret keys. |
| When a manager leaves | Change the manager password and check who can access the three accounts. |

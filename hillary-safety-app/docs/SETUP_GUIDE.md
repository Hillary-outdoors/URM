# Setup guide

This takes you from nothing to a working system. Allow about 90 minutes. Do the steps in order.

You do not need to install anything on your computer. Everything is done in a web browser.

## Before you start

**Use an organisation email address for all three accounts**, not a personal one. A shared mailbox such as `safety-system@…` is ideal. Whoever owns these accounts owns the system. If they belong to one person and that person leaves, the organisation can be locked out.

You need three accounts:

| Account | Website | Cost to know about |
|---|---|---|
| Supabase | supabase.com | The Free plan has **no backups** and **pauses the project after a week with no use**. For real use, plan on the Pro plan (about US$25 a month at the time of writing). |
| GitHub | github.com | Free. |
| Vercel | vercel.com | The free Hobby plan is for personal, non-commercial use only. An organisation should expect to need the Pro plan (about US$20 per user a month at the time of writing). |

Check current prices on each site before committing. You can do the whole setup on the free plans first to try it out.

Keep a note open as you go. You will collect three values:

1. Project URL
2. Publishable key
3. Secret key

---

## Step 1. Create the Supabase project

1. Sign in at supabase.com and choose **New project**.
2. Name it `hillary-safety`.
3. Set a **database password**. Use a long random one and store it in the organisation's password manager. You will rarely need it, but you cannot recover it.
4. Choose the region closest to New Zealand. Sydney is the usual choice.
5. Create the project and wait for it to finish setting up (a couple of minutes).

## Step 2. Build the database

1. In Supabase, open the **SQL Editor** (left-hand menu).
2. On your computer, open the `supabase` folder from this project. It has five files.
3. For each of the **first four** files, in number order:
   1. Open the file in Notepad (or any text editor), select everything and copy it.
   2. In the SQL Editor, start a new query, paste, and press **Run**.
   3. Wait for "Success" before doing the next file.

| File | What it does |
|---|---|
| `01_tables.sql` | Creates the 17 empty tables. |
| `02_security.sql` | Switches on the security rules. |
| `03_views_and_functions.sql` | Adds the worked-out values (competency status, AMP up to date) and the instructor actions. |
| `04_starter_data.sql` | Adds the two centres, Tongariro and Coromandel. |

Do not run file 5 yet.

**If a file fails:** read the red message. The most common cause is running the files out of order, or running one twice. On a brand-new project it is safe to delete the project and start Step 1 again.

**Check:** open **Table Editor**. You should see 17 tables, and `centres` should have two rows.

## Step 3. Lock down sign-ups

Only managers should be able to create logins.

1. Open **Authentication**, then its settings for sign-in or providers.
2. Find **Allow new users to sign up** and switch it **off**.
3. Under the Email provider, switch **Confirm email** off. Managers create logins directly, so no confirmation email is needed.
4. Set the minimum password length to **10**.

The names of these settings move around between Supabase versions. If you cannot find one, search the Supabase docs for the phrase in bold.

## Step 4. Create the manager login

1. Open **Authentication → Users → Add user → Create new user**.
2. Enter the manager email address and a strong password. Tick **Auto Confirm User** if it is offered.
3. Go back to the **SQL Editor**.
4. Open `05_make_manager_account.sql`, copy it in, and **change `CHANGE-ME@example.com` to the manager email** you just used.
5. Run it. The result should show one row: `Manager | manager`.

That login now sees the manager side of the app. Every other login is an instructor.

## Step 5. Collect the three values

1. In Supabase, open **Project Settings → API Keys** (the green **Connect** button at the top also shows these).
2. Copy the **Project URL**. It looks like `https://abcdefgh.supabase.co`.
3. Copy the **Publishable key**. It starts `sb_publishable_`.
4. Copy the **Secret key**. It starts `sb_secret_`. You may need to press a reveal or create button first.

The publishable key is safe to be public. **The secret key is not.** It can read and change everything. It only ever goes into Vercel in Step 7. Never paste it into GitHub, an email or a chat.

Older Supabase projects call these two keys `anon` and `service_role`. The app accepts either kind.

## Step 6. Put the code on GitHub

1. Sign in at github.com and choose **New repository**.
2. Name it `hillary-safety-app`. Set it to **Private**. Do not add a README. Create it.
3. On the empty repository page, choose **uploading an existing file**.
4. On your computer, open the project folder. Select **everything inside it** and drag it onto the GitHub page.
5. Wait for all files to upload, then press **Commit changes**.

Two things to check after the upload:

- The repository should show the folders `app`, `components`, `docs`, `lib`, `supabase` and files including `package.json` at the top level. If they are all inside one extra folder, Vercel will not find them. Delete the repository and upload again from inside the folder.
- Files whose names start with a dot (`.gitignore`, `.env.example`) are sometimes hidden on your computer and get missed. That is fine. The app works without them.

Do not upload folders called `node_modules` or `.next` if you ever see them. They are not part of the source.

## Step 7. Publish with Vercel

1. Sign in at vercel.com **using the GitHub account** from Step 6.
2. Choose **Add New → Project**, find `hillary-safety-app`, and press **Import**. If the repository is not listed, follow Vercel's prompt to give it access to that repository.
3. Vercel should detect **Next.js** on its own. Leave the build settings alone.
4. Open **Environment Variables** and add these three. The names must match exactly:

| Name | Value |
|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | the Project URL |
| `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | the Publishable key |
| `SUPABASE_SECRET_KEY` | the Secret key |

5. Press **Deploy** and wait a couple of minutes.
6. Vercel gives you a web address ending `.vercel.app`. That is the app.

**If you add or change a variable later**, you must redeploy for it to take effect: **Deployments → the latest one → Redeploy**.

## Step 8. Tell Supabase the app's address

1. In Supabase, open **Authentication → URL Configuration**.
2. Set **Site URL** to your `.vercel.app` address.

## Step 9. First sign-in

1. Open the app address and sign in with the manager login.
2. You should land on **Today's intentions**.
3. Press **Turn on overdue alerts** (top right) and allow notifications when the browser asks.

If the login page shows a red box saying the app is not connected, a variable in Step 7 is missing or misnamed. Fix it and redeploy.

## Step 10. Enter the data, in this order

The order matters because later items point at earlier ones.

| Order | Where | What |
|---|---|---|
| 1 | Edit → **Instructors** | Add each instructor. This creates their login. Give them the starting password in person. |
| 2 | Edit → **AMPs** | Create each AMP. This also creates the activity. Set its call-in type and whether it is inside the national park. Fill in the boxes and **publish**. |
| 3 | Edit → **Competencies** | Create each competency, pick the **activity it unlocks**, then add its lines and untick the greyed boxes. |
| 4 | **Instructor profile** | Enter existing sign-offs. Use **Sign off whole competency** for people who are already fully signed off on paper. |

Start small. Enter two instructors, one AMP and one competency, and run a pretend day with them before entering the rest.

## Step 11. Put it on phones and the duty laptop

**Instructors:** open the app address in the phone's browser, sign in, then use the browser menu's **Add to Home Screen**. It then opens like an app.

**Duty Manager device:** keep the manager page open on the laptop or phone that is on duty, with alerts turned on. The ding and the notification only work while that page is open in a browser. If the laptop sleeps or the tab is closed, there is no alert. Set the duty laptop not to sleep.

---

## Changing the app later

Any change committed to GitHub is picked up by Vercel and published within a couple of minutes. To change one file, open it on GitHub, press the pencil, edit, and commit.

If a change breaks something, open Vercel → **Deployments**, find the last working one, and choose **Promote to Production** (or **Rollback**).

## When something goes wrong

| What you see | Likely cause | Fix |
|---|---|---|
| Red box on the login page | A Vercel variable is missing or misnamed | Check the three names in Step 7, then redeploy |
| "Email and password did not match" for the manager | Wrong password, or the user was never confirmed | Reset the password in Supabase → Authentication → Users |
| Manager lands on the instructor side | File 5 was not run, or was run with the wrong email | Run file 5 again with the right email |
| "Your login is not linked to an instructor record" | The login was created in Supabase, not in the app | Add instructors through Edit → Instructors |
| Adding an instructor says the server is missing the secret key | `SUPABASE_SECRET_KEY` is not set in Vercel | Add it and redeploy |
| Everything stopped working after a quiet week | A Free-plan Supabase project has paused | Open Supabase and press Restore. Move to the Pro plan to stop this |
| No ding when someone is overdue | Alerts not turned on, tab closed, or device muted or asleep | Turn alerts on, keep the page open, check the volume |
| A screen shows a red error message | A database rule refused the action, or a bug | Note the message and what you clicked, and report it |

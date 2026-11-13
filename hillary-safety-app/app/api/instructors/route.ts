import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

/**
 * Server-only API for managing logins. It is the one place the secret
 * key is used, and it never leaves the server.
 *
 *   POST  /api/instructors  create an instructor and their login
 *   PATCH /api/instructors  reset a password, or switch a login off or on
 *
 * Every call must come from a logged-in manager.
 */
export const dynamic = 'force-dynamic';

function admin() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL, key = process.env.SUPABASE_SECRET_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY; // second name = older projects
  if (!url || !key) return null;
  return createClient(url, key, { auth: { persistSession: false, autoRefreshToken: false } });
}

async function requireManager(req: Request, db: any) {
  const token = (req.headers.get('authorization') || '').replace(/^Bearer /i, '');
  if (!token) return null;
  const { data, error } = await db.auth.getUser(token);
  if (error || !data?.user) return null;
  const { data: row } = await db.from('instructors').select('account_type').eq('auth_user_id', data.user.id).maybeSingle();
  return row?.account_type === 'manager' ? data.user : null;
}

const bad = (message: string, status = 400) => NextResponse.json({ error: message }, { status });

export async function POST(req: Request) {
  const db = admin();
  if (!db) return bad('The server is missing SUPABASE_SECRET_KEY. Add it in Vercel and redeploy.', 500);
  if (!(await requireManager(req, db))) return bad('Only a manager can do this.', 403);

  const b = await req.json().catch(() => ({}));
  const name = String(b.name || '').trim(), email = String(b.email || '').trim().toLowerCase(), password = String(b.password || '');
  if (!name) return bad('A name is needed.');
  if (!/^\S+@\S+\.\S+$/.test(email)) return bad('That email address does not look right.');
  if (password.length < 10) return bad('The starting password must be at least 10 characters.');
  const employment = ['Staff', 'Contractor', 'Past staff'].includes(b.employment) ? b.employment : 'Staff';

  const { data: created, error } = await db.auth.admin.createUser({ email, password, email_confirm: true });
  if (error || !created?.user) return bad(error?.message || 'Could not create the login.');

  const { data: row, error: e2 } = await db.from('instructors').insert({
    auth_user_id: created.user.id, name, initials: b.initials || null, centre_id: b.centre_id || null,
    employment, start_date: b.start_date || null, account_type: 'instructor',
  }).select().single();
  if (e2) { await db.auth.admin.deleteUser(created.user.id); return bad(e2.message); }
  return NextResponse.json({ instructor: row });
}

export async function PATCH(req: Request) {
  const db = admin();
  if (!db) return bad('The server is missing SUPABASE_SECRET_KEY. Add it in Vercel and redeploy.', 500);
  if (!(await requireManager(req, db))) return bad('Only a manager can do this.', 403);

  const b = await req.json().catch(() => ({}));
  const { data: row } = await db.from('instructors').select('auth_user_id, account_type').eq('id', b.instructor_id).maybeSingle();
  if (!row?.auth_user_id) return bad('That person has no login.');
  if (row.account_type === 'manager') return bad('Change the manager login in the Supabase dashboard, not here.');

  const change: any = {};
  if (b.password !== undefined) {
    if (String(b.password).length < 10) return bad('The new password must be at least 10 characters.');
    change.password = String(b.password);
  }
  if (b.disabled !== undefined) change.ban_duration = b.disabled ? '876000h' : 'none'; // about 100 years = switched off
  if (!Object.keys(change).length) return bad('Nothing to change.');
  const { error } = await db.auth.admin.updateUserById(row.auth_user_id, change);
  if (error) return bad(error.message);
  return NextResponse.json({ ok: true });
}

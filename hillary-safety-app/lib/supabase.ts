import { createClient } from '@supabase/supabase-js';

// What each person can see or change is decided by the database's
// row-level security rules (supabase/02_security.sql), not by this app.
// The browser talks straight to Supabase with the publishable key (safe to be public).
const realUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const realKey = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY; // second name = older projects

export const supabase = createClient(realUrl || 'https://placeholder.supabase.co', realKey || 'placeholder');
export const configured = !!realUrl && !!realKey;

/** Who is logged in, and which instructors row is theirs. */
export async function getMe() {
  const { data } = await supabase.auth.getSession();
  const user = data.session?.user;
  if (!user) return null;
  const { data: me } = await supabase.from('instructors').select('*').eq('auth_user_id', user.id).maybeSingle();
  return { user, me };
}

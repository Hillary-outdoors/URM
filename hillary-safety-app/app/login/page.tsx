'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase, configured } from '@/lib/supabase';
import { Logo } from '@/components/Logo';

/** One login screen for everyone. The account decides which side you land on. */
export default function Login() {
  const router = useRouter();
  const [email, setEmail] = useState(''); const [password, setPassword] = useState('');
  const [msg, setMsg] = useState(''); const [busy, setBusy] = useState(false);

  async function go(e: React.FormEvent) {
    e.preventDefault(); setBusy(true); setMsg('');
    const { error } = await supabase.auth.signInWithPassword({ email: email.trim(), password });
    setBusy(false);
    if (error) { setMsg('That email and password did not match. Try again, or ask a manager to reset your password.'); return; }
    router.replace('/');
  }

  return (
    <div className="login">
      <Logo size={40} sub="Universal Record Management App" />
      <p className="muted" style={{ marginTop: 8 }}>Hillary Outdoors</p>
      {!configured && <div className="inc">The app is not connected to Supabase yet. Add the three environment variables in Vercel, then redeploy. See docs/SETUP_GUIDE.md.</div>}
      <form className="card" onSubmit={go}>
        <label className="f" htmlFor="em">Email</label>
        <input id="em" type="email" autoComplete="username" value={email} onChange={(e) => setEmail(e.target.value)} required />
        <label className="f" htmlFor="pw">Password</label>
        <input id="pw" type="password" autoComplete="current-password" value={password} onChange={(e) => setPassword(e.target.value)} required />
        <div className="msg bad">{msg}</div>
        <button className="btn primary" style={{ width: '100%' }} disabled={busy}>{busy ? 'Signing in…' : 'Sign in'}</button>
      </form>
      <p className="muted" style={{ fontSize: 13 }}>Instructors and managers sign in here. There is no public sign-up: a manager creates each login.</p>
    </div>
  );
}

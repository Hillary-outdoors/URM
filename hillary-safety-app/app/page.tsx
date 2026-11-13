'use client';
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { getMe } from '@/lib/supabase';

/** Front door: sends each person to the right screen for their account. */
export default function Home() {
  const router = useRouter();
  useEffect(() => {
    getMe().then((r) => {
      if (!r) router.replace('/login');
      else if (r.me?.account_type === 'manager') router.replace('/manager');
      else router.replace('/instructor');
    });
  }, [router]);
  return <div className="login muted">Loading…</div>;
}

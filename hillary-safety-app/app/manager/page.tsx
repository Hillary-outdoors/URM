'use client';
import { useCallback, useEffect, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase, getMe } from '@/lib/supabase';
import { INT_SELECT, shapeInt, lateMinutes, lateLevel, beep, nzToday, hm } from '@/lib/util';
import Today from '@/components/manager/Today';
import History from '@/components/manager/History';
import MatrixTab from '@/components/manager/MatrixTab';
import Profile from '@/components/manager/Profile';
import ChangeLog from '@/components/manager/ChangeLog';
import Amps from '@/components/manager/Amps';
import Competencies from '@/components/manager/Competencies';
import People from '@/components/manager/People';
import Export from '@/components/manager/Export';

const TABS: [string, string, string?][] = [
  ['today', "Today's intentions"], ['history', 'Intention history'], ['matrix', 'Who can run what'], ['profile', 'Instructor profile'], ['log', 'Change log'],
  ['amps', 'AMPs', 'Edit'], ['comps', 'Competencies'], ['people', 'Instructors'], ['export', 'Export', 'Audit'],
];

/** The manager side. Loads the shared lists once, then shows one tab at a time. */
export default function ManagerApp() {
  const router = useRouter();
  const [ready, setReady] = useState(false); const [err, setErr] = useState('');
  const [tab, setTab] = useState('today');
  const [base, setBase] = useState<any>({ centres: [], instructors: [], activities: [], amps: [], comps: [] });
  const [pulse, setPulse] = useState(0);          // goes up every 30 seconds so the board refreshes
  const [alerts, setAlerts] = useState(false);    // has the manager switched alert sound on?
  const alerted = useRef<Record<number, number>>({});

  const loadBase = useCallback(async () => {
    const [c, i, a, m, k] = await Promise.all([
      supabase.from('centres').select('*').order('id'),
      supabase.from('instructors').select('*').order('name'),
      supabase.from('activities').select('*').order('name'),
      supabase.from('amps').select('id,act_id,title,version').order('title'),
      supabase.from('competencies').select('id,name,level,act_id,centre_id').order('level').order('name'),
    ]);
    const bad = [c, i, a, m, k].find((r) => r.error); if (bad) setErr(bad.error!.message);
    setBase({ centres: c.data || [], instructors: i.data || [], activities: a.data || [], amps: m.data || [], comps: k.data || [] });
  }, []);

  useEffect(() => {
    getMe().then(async (r) => {
      if (!r) return router.replace('/login');
      if (r.me?.account_type !== 'manager') return router.replace('/instructor');
      await loadBase(); setReady(true);
    });
  }, [router, loadBase]);

  // Overdue watch: runs on every manager tab, every 30 seconds.
  useEffect(() => {
    if (!ready) return;
    const check = async () => {
      const { data } = await supabase.from('intentions').select(INT_SELECT).neq('status', 'Closed').not('due_by', 'is', null).lte('date', nzToday());
      let worst = 0;
      (data || []).map(shapeInt).forEach((i: any) => {
        const lv = lateLevel(lateMinutes(i, base.activities));
        if (lv > (alerted.current[i.id] || 0)) {
          worst = Math.max(worst, lv);
          const who = i.who.map((w: string) => base.instructors.find((x: any) => x.id === w)?.name).filter(Boolean).join(' + ');
          try {
            if ('Notification' in window && Notification.permission === 'granted')
              new Notification((lv === 2 ? 'RED: ' : 'Yellow: ') + who + ' not called in', { body: 'Due ' + hm(i.due_by) + '. Open the Safety System.', requireInteraction: lv === 2 });
          } catch (e) { /* notifications not available */ }
        }
        alerted.current[i.id] = lv;
      });
      if (worst && alerts) beep(worst === 2 ? 6 : 3);
      setPulse((p) => p + 1);
    };
    check();
    const t = setInterval(check, 30000);
    return () => clearInterval(t);
  }, [ready, alerts, base.activities, base.instructors]);

  async function enableAlerts() {
    beep(1); setAlerts(true);
    try { if ('Notification' in window && Notification.permission === 'default') await Notification.requestPermission(); } catch (e) { /* ignore */ }
  }

  if (!ready) return <div className="login muted">Loading…</div>;
  const p = { base, reload: loadBase, pulse };
  return (
    <>
      <div className="appbar">
        <h1>Hillary Outdoors <span>Safety System</span></h1><small>Manager</small>
        <div className="sp">
          <button className={'btn small' + (alerts ? ' alert-on' : '')} onClick={alerts ? () => setAlerts(false) : enableAlerts}>{alerts ? 'Overdue alerts: On' : 'Turn on overdue alerts'}</button>
          <button className="btn small" onClick={async () => { await supabase.auth.signOut(); router.replace('/login'); }}>Sign out</button>
        </div>
      </div>
      <div className="wrap">
        {err && <div className="inc">{err}</div>}
        {!alerts && <div className="hl">Overdue alerts are off on this device. Turn them on (top right) so it dings and shows a notification when someone has not called in. Keep this page open on the duty laptop or phone.</div>}
        <div className="mtabs">
          {TABS.map(([k, l, group]) => (
            <span key={k} style={{ display: 'contents' }}>
              {group && <span className="mdiv">{group}</span>}
              <button className={tab === k ? 'on' : ''} onClick={() => setTab(k)}>{l}</button>
            </span>
          ))}
        </div>
        {tab === 'today' && <Today {...p} />}
        {tab === 'history' && <History {...p} />}
        {tab === 'matrix' && <MatrixTab {...p} />}
        {tab === 'profile' && <Profile {...p} />}
        {tab === 'log' && <ChangeLog />}
        {tab === 'amps' && <Amps {...p} />}
        {tab === 'comps' && <Competencies {...p} />}
        {tab === 'people' && <People {...p} />}
        {tab === 'export' && <Export {...p} />}
      </div>
    </>
  );
}

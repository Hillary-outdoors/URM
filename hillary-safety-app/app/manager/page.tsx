'use client';
import { useCallback, useEffect, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase, getMe } from '@/lib/supabase';
import { Logo } from '@/components/Logo';
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
import TrainingLogs from '@/components/manager/TrainingLogs';

const TABS: [string, string, string?][] = [
  ['today', "Today's intentions"], ['history', 'Intention history'], ['matrix', 'Who can run what'], ['profile', 'Instructor profile'], ['logs', 'Training log'], ['log', 'Change log'],
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
  /**
   * The state of the overdue watch itself. `ok` is when it last got a real answer, and it is on
   * screen on purpose: a clock that has gone stale is something a DM can see, where a watch that
   * has quietly stopped is not. `dead` means the session is gone and nothing is being checked.
   */
  const [watch, setWatch] = useState<{ ok: Date | null; fails: number; dead: boolean; msg: string }>(
    { ok: null, fails: 0, dead: false, msg: '' });

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
      await loadBase();
      setBase((b: any) => ({ ...b, me: r.me }));   // who is signed in, for anything that records an author
      setReady(true);
    });
  }, [router, loadBase]);

  /**
   * Overdue watch: runs on every manager tab, every 30 seconds.
   *
   * It used to throw the error away and read a failed request as "nobody is overdue", so when a
   * login expired overnight the watch went silent and the screen looked completely normal. Now a
   * failure is noticed, a dead session stops the watch and says so on screen, and repeated failures
   * back off instead of hammering the server thousands of times.
   */
  useEffect(() => {
    if (!ready) return;
    let stopped = false;
    let timer: any = null;
    let fails = 0;

    // 30 seconds normally; after a failure 1, 2, 4, 8 minutes, capped there.
    const delay = () => (fails === 0 ? 30000 : Math.min(60000 * Math.pow(2, Math.min(fails - 1, 3)), 480000));
    const schedule = () => { if (!stopped) timer = setTimeout(run, delay()); };

    async function run() {
      if (stopped) return;
      // No point asking while the laptop is off the network.
      if (typeof navigator !== 'undefined' && navigator.onLine === false) { schedule(); return; }

      const { data, error } = await supabase.from('intentions').select(INT_SELECT)
        .neq('status', 'Closed').not('due_by', 'is', null).lte('date', nzToday());

      if (error) {
        fails += 1;
        // A session that will not refresh is not a hiccup. Nothing is being watched until
        // somebody signs in again, and that has to be said out loud.
        const { data: s } = await supabase.auth.getSession();
        const dead = !s?.session;
        setWatch((w) => ({ ...w, fails, dead, msg: dead ? 'Your login has expired.' : error.message }));
        if (dead) { stopped = true; return; }
        schedule();
        return;
      }

      fails = 0;
      setWatch({ ok: new Date(), fails: 0, dead: false, msg: '' });

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
      schedule();
    }

    // Back on the network, or back to this tab: check straight away rather than waiting out a backoff.
    const wake = () => { if (!stopped) { clearTimeout(timer); fails = 0; run(); } };
    const onVisible = () => { if (!document.hidden) wake(); };
    window.addEventListener('online', wake);
    document.addEventListener('visibilitychange', onVisible);

    run();
    return () => {
      stopped = true; clearTimeout(timer);
      window.removeEventListener('online', wake);
      document.removeEventListener('visibilitychange', onVisible);
    };
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
        <Logo size={30} /><small>Hillary Outdoors · Manager</small>
        <div className="sp">
          {/* Deliberately always visible. A stale time is a problem you can see. */}
          <small className="muted" title="When the overdue watch last got an answer from the server">
            {watch.dead ? 'Overdue watch: STOPPED'
              : watch.ok ? 'Checked ' + watch.ok.toLocaleTimeString('en-NZ', { hour: '2-digit', minute: '2-digit', hour12: false })
              : 'Checking…'}
          </small>
          <button className={'btn small' + (alerts ? ' alert-on' : '')} onClick={alerts ? () => setAlerts(false) : enableAlerts}>{alerts ? 'Overdue alerts: On' : 'Turn on overdue alerts'}</button>
          <button className="btn small" onClick={async () => { await supabase.auth.signOut(); router.replace('/login'); }}>Sign out</button>
        </div>
      </div>
      <div className="wrap">
        {watch.dead && (
          <div className="inc">
            <b>Nobody is watching the clock.</b> {watch.msg} Until you sign in again, the overdue
            alarm is not running and nothing on this screen is being refreshed.
            <div style={{ marginTop: 8 }}>
              <button className="btn primary" onClick={async () => { await supabase.auth.signOut(); router.replace('/login'); }}>Sign in again</button>
            </div>
          </div>
        )}
        {!watch.dead && watch.fails > 0 && (
          <div className="hl">
            <b>Cannot reach the server.</b> The overdue watch has failed {watch.fails} time{watch.fails === 1 ? '' : 's'} in a row
            and is still retrying{watch.msg ? ' — ' + watch.msg : ''}. Check this laptop is online.
          </div>
        )}
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
        {tab === 'logs' && <TrainingLogs {...p} />}
        {tab === 'log' && <ChangeLog />}
        {tab === 'amps' && <Amps {...p} />}
        {tab === 'comps' && <Competencies {...p} />}
        {tab === 'people' && <People {...p} />}
        {tab === 'export' && <Export {...p} />}
      </div>
    </>
  );
}

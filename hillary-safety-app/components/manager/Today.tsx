'use client';
import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { SAFE, INT_SELECT, shapeInt, needsCall, lateMinutes, lateLevel, loadChecks, issues, nzToday, nzNow, fd, hm, Checks } from '@/lib/util';
import { Pill, Sheet } from '@/components/ui';
import IntentionTable from './IntentionTable';
import { IntentionSheet, AddIntention } from './IntentionSheet';

const DAY0 = { dm_name: '', wx_state: 'Green', wx_events: 'None', avalanche: 'Nil', closures: '', wx_notes: '', river_levels: '', dm_judgements: '' };

/** The duty manager's page: day sheet, open intentions with call-in buttons, and the comms log. */
export default function Today({ base, pulse }: any) {
  const today = nzToday();
  const [centre, setCentre] = useState<number>(0);
  const [day, setDay] = useState<any>(DAY0); const [ints, setInts] = useState<any[]>([]); const [comms, setComms] = useState<any[]>([]);
  const [checks, setChecks] = useState<Checks>({ comp: {}, amp: {} });
  const [sel, setSel] = useState<any>(null); const [adding, setAdding] = useState(false); const [calling, setCalling] = useState(0);
  const [c, setC] = useState({ time: '', who: '', entry: '' }); const [err, setErr] = useState('');

  useEffect(() => {
    let saved = 0; try { saved = +(localStorage.getItem('centre') || 0); } catch (e) { /* ignore */ }
    setCentre(base.centres.find((x: any) => x.id === saved)?.id || base.centres[0]?.id || 0);
  }, [base.centres]);

  const loadDay = useCallback(async () => {
    if (!centre) return;
    const { data } = await supabase.from('dm_day_logs').select('*').eq('date', today).eq('centre_id', centre).maybeSingle();
    let name = ''; try { name = localStorage.getItem('dmName') || ''; } catch (e) { /* ignore */ }
    setDay(data ? { ...DAY0, ...Object.fromEntries(Object.entries(data).filter(([, v]) => v !== null)) } : { ...DAY0, dm_name: name });
  }, [centre, today]);
  const load = useCallback(async () => {
    if (!centre) return;
    // Everything still open, including anything left open from an earlier day.
    const [i, m] = await Promise.all([
      supabase.from('intentions').select(INT_SELECT).eq('centre_id', centre).neq('status', 'Closed').lte('date', today).order('date').order('id'),
      supabase.from('comms_log').select('*').eq('centre_id', centre).eq('date', today).order('time'),
    ]);
    if (i.error) setErr(i.error.message);
    const list = (i.data || []).map(shapeInt);
    setInts(list); setComms(m.data || []);
    setChecks(await loadChecks([...new Set(list.flatMap((x: any) => x.who))] as string[], [...new Set(list.flatMap((x: any) => x.acts))] as number[]));
  }, [centre, today]);
  useEffect(() => { loadDay(); }, [loadDay]);
  useEffect(() => { load(); }, [load, pulse]);

  async function saveDay(patch: any) {
    const next = { ...day, ...patch }; setDay(next);
    if (patch.dm_name !== undefined) try { localStorage.setItem('dmName', patch.dm_name); } catch (e) { /* ignore */ }
    const { id, ...fields } = next;
    const { error } = await supabase.from('dm_day_logs').upsert({ ...fields, date: today, centre_id: centre }, { onConflict: 'date,centre_id' });
    if (error) setErr(error.message);
  }
  const text = (k: string, label: string, wide?: boolean, area?: boolean) => (
    <div style={wide ? { gridColumn: '1 / -1' } : undefined}>
      <label className="f" htmlFor={'d-' + k}>{label}</label>
      {area ? <textarea id={'d-' + k} rows={3} value={day[k]} onChange={(e) => setDay({ ...day, [k]: e.target.value })} onBlur={(e) => saveDay({ [k]: e.target.value })} />
        : <input id={'d-' + k} type="text" value={day[k]} onChange={(e) => setDay({ ...day, [k]: e.target.value })} onBlur={(e) => saveDay({ [k]: e.target.value })} />}
    </div>
  );
  const pick = (k: string, label: string, opts: string[]) => (
    <div><label className="f" htmlFor={'d-' + k}>{label}</label>
      <select id={'d-' + k} value={day[k]} onChange={(e) => saveDay({ [k]: e.target.value })}>{opts.map((o) => <option key={o}>{o}</option>)}</select></div>
  );

  const logStart = async (i: any) => { await supabase.from('intentions').update({ started_at: nzNow() }).eq('id', i.id); load(); };
  const callIn = async (i: any, as: string) => { const { error } = await supabase.rpc('call_in_safe', { p_intention: i.id, p_as: as }); if (error) setErr(error.message); setCalling(0); load(); };
  async function addComms() {
    if (!c.entry.trim()) return;
    const { error } = await supabase.from('comms_log').insert({ date: today, centre_id: centre, time: c.time || nzNow(), instructor_id: c.who || null, entry: c.entry.trim() });
    if (error) setErr(error.message); setC({ time: '', who: '', entry: '' }); load();
  }

  const nm = (id: string) => base.instructors.find((x: any) => x.id === id)?.name || '?';
  const an = (id: number) => base.activities.find((x: any) => x.id === id)?.name || '?';
  const lateList = (lv: number) => ints.filter((i) => lateLevel(lateMinutes(i, base.activities)) === lv);
  const flags = ints.filter((i) => i.status === 'Waiting' && issues(i, checks, base.instructors, base.activities).length).length;
  const line = (i: any) => <div key={i.id}><b>{i.who.map(nm).join(' + ')}</b> · {i.acts.map(an).join(' + ')} · due {hm(i.due_by)} · {lateMinutes(i, base.activities)} min overdue</div>;
  const onBoard = [...new Set(ints.flatMap((i) => i.who))] as string[];

  return (
    <>
      {err && <div className="inc">{err}</div>}
      <div className="mpanel" style={{ marginBottom: 14 }}>
        <div className="filters" style={{ marginBottom: 6 }}>
          <h3 style={{ fontSize: 16, alignSelf: 'center' }}>Day sheet · {fd(today)}</h3>
          <div><div className="seg">{base.centres.map((x: any) => <button key={x.id} className={centre === x.id ? 'on' : ''} onClick={() => { setCentre(x.id); try { localStorage.setItem('centre', String(x.id)); } catch (e) { /* ignore */ } }}>{x.name}</button>)}</div></div>
          <div className="muted" style={{ marginLeft: 'auto', alignSelf: 'center', fontSize: 13 }}>Saves as you go</div>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(170px,1fr))', gap: '0 14px' }}>
          {text('dm_name', 'DM')}{pick('wx_state', 'Weather state', ['Green', 'Yellow', 'Red'])}{pick('wx_events', 'Weather events', ['None', 'Watch', 'Warning'])}
          {pick('avalanche', 'Avalanche', ['Nil', 'Green', 'Yellow', 'Orange', 'Red', 'Black'])}{text('river_levels', 'River levels')}{text('closures', 'Closures')}
          {text('wx_notes', 'Weather notes and other', true)}{text('dm_judgements', 'DM judgements and discussions', true, true)}
        </div>
      </div>

      <div className="mpanel" style={{ marginBottom: 14 }}>
        <div className="filters">
          <h3 style={{ fontSize: 16, alignSelf: 'center' }}>Open intentions</h3>
          <button className="btn" onClick={() => setAdding(true)}>+ Add intention</button>
          <div style={{ marginLeft: 'auto', alignSelf: 'center' }}>{flags ? <Pill kind="bad">{flags} need a decision</Pill> : <Pill kind="good">Nothing flagged</Pill>}</div>
        </div>
        {!!lateList(2).length && <div className="inc"><b>Red: not called in, more than 20 minutes overdue</b>{lateList(2).map(line)}</div>}
        {!!lateList(1).length && <div className="hl"><b>Yellow: not called in, more than 10 minutes overdue</b>{lateList(1).map(line)}</div>}
        <IntentionTable rows={ints} base={base} checks={checks} showDate={ints.some((i) => i.date !== today)} onOpen={setSel} actions={(i) => {
          if (calling === i.id) return <div style={{ display: 'grid', gap: 4 }}>{SAFE.map((s) => <button key={s} className="btn small primary" onClick={() => callIn(i, s)}>{s}</button>)}</div>;
          if (!needsCall(i, base.activities)) return <button className="btn small" onClick={() => callIn(i, 'Day finished')}>Close</button>;
          return <>{!i.started_at && <button className="btn small primary" onClick={() => logStart(i)}>Log start</button>}
            <button className={'btn small' + (i.started_at ? ' primary' : '')} onClick={() => setCalling(i.id)}>Call in safe</button></>;
        }} />
        <p className="muted" style={{ fontSize: 13, margin: '10px 0 0' }}>Only cave, water, mountain and overnight activities are timed and called in. An intention stays open until someone calls in safe. 10 minutes past the due time it turns yellow, 20 minutes past it turns red.</p>
      </div>

      <div className="mpanel">
        <h3 style={{ fontSize: 16, marginBottom: 8 }}>Comms log</h3>
        {comms.length ? comms.map((m) => <div className="thread" key={m.id}><small>{hm(m.time)}{m.instructor_id ? ' · ' + nm(m.instructor_id) : ''}</small>{m.entry}</div>) : <p className="muted" style={{ margin: 0 }}>Nothing logged yet today.</p>}
        <div className="filters" style={{ margin: '12px 0 0' }}>
          <div style={{ maxWidth: 120, minWidth: 100 }}><label className="f" style={{ marginTop: 0 }} htmlFor="c-time">Time</label><input id="c-time" type="time" value={c.time || nzNow()} onChange={(e) => setC({ ...c, time: e.target.value })} /></div>
          <div><label className="f" style={{ marginTop: 0 }} htmlFor="c-who">Instructor</label>
            <select id="c-who" value={c.who} onChange={(e) => setC({ ...c, who: e.target.value })}><option value="">General</option>{onBoard.map((w) => <option key={w} value={w}>{nm(w)}</option>)}</select></div>
          <div style={{ flex: 1, minWidth: 240 }}><label className="f" style={{ marginTop: 0 }} htmlFor="c-text">Entry</label>
            <input id="c-text" type="text" value={c.entry} onChange={(e) => setC({ ...c, entry: e.target.value })} onKeyDown={(e) => { if (e.key === 'Enter') addComms(); }} placeholder="For example: entering caves, 9 participants, water level 0, out at 2pm" /></div>
          <button className="btn primary" onClick={addComms}>Log it</button>
        </div>
      </div>

      <Sheet open={!!sel} onClose={() => setSel(null)}>{sel && <IntentionSheet intention={sel} base={base} onDone={() => { setSel(null); load(); loadDay(); }} />}</Sheet>
      <Sheet open={adding} onClose={() => setAdding(false)}><AddIntention base={base} centreId={centre} onDone={() => { setAdding(false); load(); }} /></Sheet>
    </>
  );
}

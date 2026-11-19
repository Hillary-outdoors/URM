'use client';
import { useCallback, useEffect, useRef, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { INT_SELECT, shapeInt, needsCall, lateMinutes, lateLevel, loadChecks, issues, nzToday, nzNow, fd, hm, Checks } from '@/lib/util';
import { Pill, Sheet } from '@/components/ui';
import IntentionTable from './IntentionTable';
import DayConditions from './DayConditions';
import TakeSheet from './TakeSheet';
import { IntentionSheet, AddIntention } from './IntentionSheet';

const DAY0 = { dm_name: '', wx_state: 'Green', wx_events: 'None', avalanche: 'Nil', closures: '', wx_notes: '',
  river_levels: '', dm_judgements: '', forecast: '', tide_notes: '', sunset: '' };

/** The duty manager's page: day sheet, open intentions with call-in buttons, and the comms log. */
export default function Today({ base, pulse }: any) {
  const today = nzToday();
  const [centre, setCentre] = useState<number>(0);
  const [day, setDay] = useState<any>(DAY0); const [ints, setInts] = useState<any[]>([]); const [comms, setComms] = useState<any[]>([]);
  const [checks, setChecks] = useState<Checks>({ comp: {}, amp: {} });
  const [sel, setSel] = useState<any>(null); const [adding, setAdding] = useState(false); const [calling, setCalling] = useState(0);
  const [c, setC] = useState({ time: '', who: '', entry: '' }); const [err, setErr] = useState('');
  const [sheet, setSheet] = useState(false);
  const [opts, setOpts] = useState<any[]>([]);          // the call list, from the database
  const [calls, setCalls] = useState<Record<number, any[]>>({});
  const [note, setNote] = useState('');                 // free text for a call that is not on the list

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
    const ids = list.map((x: any) => x.id);
    if (ids.length) {
      const { data: cl } = await supabase.from('intention_calls').select('*').in('intention_id', ids).order('at');
      const by: Record<number, any[]> = {};
      (cl || []).forEach((x: any) => { (by[x.intention_id] ||= []).push(x); });
      setCalls(by);
    } else setCalls({});
    setChecks(await loadChecks([...new Set(list.flatMap((x: any) => x.who))] as string[], [...new Set(list.flatMap((x: any) => x.acts))] as number[]));
  }, [centre, today]);
  useEffect(() => { loadDay(); }, [loadDay]);
  useEffect(() => { supabase.from('call_options').select('*').order('sort_order').then(({ data }) => setOpts(data || [])); }, []);
  useEffect(() => { load(); }, [load, pulse]);

  const timer = useRef<any>(null);

  /**
   * Writes the day sheet. Empty boxes have to go in as null, never as '': an empty string is not a
   * valid time, and one bad value makes Postgres reject the whole row. That is why the day sheet
   * never saved at a centre with no sunset box on it.
   */
  const pushDay = useCallback(async (next: any) => {
    const { id, ...fields } = next;
    const clean = Object.fromEntries(Object.entries(fields).map(([k, v]) => [k, v === '' ? null : v]));
    const { error } = await supabase.from('dm_day_logs')
      .upsert({ ...clean, date: today, centre_id: centre }, { onConflict: 'date,centre_id' });
    setErr(error ? error.message : '');
  }, [today, centre]);

  function saveDay(patch: any) {
    const next = { ...day, ...patch }; setDay(next);
    if (patch.dm_name !== undefined) try { localStorage.setItem('dmName', patch.dm_name); } catch (e) { /* ignore */ }
    if (timer.current) { clearTimeout(timer.current); timer.current = null; }
    pushDay(next);
  }

  /** Typing saves itself a moment after you stop, so a refresh mid-sentence loses nothing. */
  function typeDay(patch: any) {
    const next = { ...day, ...patch }; setDay(next);
    if (timer.current) clearTimeout(timer.current);
    timer.current = setTimeout(() => { timer.current = null; pushDay(next); }, 900);
  }
  useEffect(() => () => { if (timer.current) clearTimeout(timer.current); }, []);
  const text = (k: string, label: string, wide?: boolean, area?: boolean) => (
    <div style={wide ? { gridColumn: '1 / -1' } : undefined}>
      <label className="f" htmlFor={'d-' + k}>{label}</label>
      {area ? <textarea id={'d-' + k} rows={3} value={day[k]} onChange={(e) => typeDay({ [k]: e.target.value })} onBlur={(e) => saveDay({ [k]: e.target.value })} />
        : <input id={'d-' + k} type="text" value={day[k]} onChange={(e) => typeDay({ [k]: e.target.value })} onBlur={(e) => saveDay({ [k]: e.target.value })} />}
    </div>
  );
  const time = (k: string, label: string) => (
    <div><label className="f" htmlFor={'d-' + k}>{label}</label>
      <input id={'d-' + k} type="time" value={day[k] ? String(day[k]).slice(0, 5) : ''}
        onChange={(e) => setDay({ ...day, [k]: e.target.value })} onBlur={(e) => saveDay({ [k]: e.target.value || '' })} /></div>
  );
  const pick = (k: string, label: string, opts: string[]) => (
    <div><label className="f" htmlFor={'d-' + k}>{label}</label>
      <select id={'d-' + k} value={day[k]} onChange={(e) => saveDay({ [k]: e.target.value })}>{opts.map((o) => <option key={o}>{o}</option>)}</select></div>
  );

  const here = base.centres.find((x: any) => x.id === centre);   // what this centre's day sheet carries
  const logStart = async (i: any) => { await supabase.from('intentions').update({ started_at: nzNow() }).eq('id', i.id); load(); };
  /** Log whatever call just came in. The wording decides whether it also closes the trip. */
  const callIn = async (i: any, words: string, closes?: boolean) => {
    if (!words.trim()) return;
    const { error } = await supabase.rpc('log_call', { p_intention: i.id, p_words: words, p_note: null, p_closes: closes ?? null });
    if (error) setErr(error.message);
    setCalling(0); setNote(''); load();
  };
  const undoCall = async (id: number) => { const { error } = await supabase.rpc('undo_call', { p_call: id }); if (error) setErr(error.message); load(); };
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

  if (sheet) return (
    <div className="mpanel">
      <TakeSheet date={today} centre={centre} centreName={here?.name || ''} coastal={!!here?.coastal}
        alpine={!!here?.alpine} onClose={() => setSheet(false)} />
    </div>
  );

  return (
    <>
      {err && <div className="inc">{err}</div>}
      <div className="mpanel" style={{ marginBottom: 14 }}>
        <div className="filters" style={{ marginBottom: 6 }}>
          <h3 style={{ fontSize: 16, alignSelf: 'center' }}>Day sheet · {fd(today)}</h3>
          <div><div className="seg">{base.centres.map((x: any) => <button key={x.id} className={centre === x.id ? 'on' : ''} onClick={() => { setCentre(x.id); try { localStorage.setItem('centre', String(x.id)); } catch (e) { /* ignore */ } }}>{x.name}</button>)}</div></div>
          <button className="btn" onClick={() => setSheet(true)}>Take sheet</button>
          <div className="muted" style={{ marginLeft: 'auto', alignSelf: 'center', fontSize: 13 }}>Saves as you go</div>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(170px,1fr))', gap: '0 14px' }}>
          {text('dm_name', 'DM')}{pick('wx_state', 'Weather state', ['Green', 'Yellow', 'Red'])}
          {text('forecast', 'Forecast')}
          {here?.coastal ? text('tide_notes', 'Tides') : null}
          {here?.coastal ? time('sunset', 'Sunset') : null}
          {text('wx_notes', 'Weather notes and other', true)}{text('dm_judgements', 'DM judgements and discussions', true, true)}
        </div>
        <DayConditions date={today} centre={centre} dmName={day.dm_name} alpine={!!here?.alpine} />
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
          const made = calls[i.id] || [];
          if (calling === i.id) return (
            <div style={{ display: 'grid', gap: 4, minWidth: 190 }}>
              {opts.map((o) => (
                <button key={o.id} className={'btn small' + (o.closes_trip ? ' primary' : '')}
                  onClick={() => callIn(i, o.words, o.closes_trip)}>{o.words}</button>
              ))}
              <div className="rowflex" style={{ gap: 4 }}>
                <input type="text" placeholder="Something else…" value={note} style={{ minWidth: 110 }}
                  onChange={(e) => setNote(e.target.value)} onKeyDown={(e) => { if (e.key === 'Enter') callIn(i, note, false); }} />
                <button className="btn small" onClick={() => callIn(i, note, false)}>Log</button>
              </div>
              <button className="btn small" onClick={() => { setCalling(0); setNote(''); }}>Cancel</button>
            </div>
          );
          return <>
            {!i.started_at && <button className="btn small primary" onClick={() => logStart(i)}>Log start</button>}
            <button className={'btn small' + (i.started_at ? ' primary' : '')} onClick={() => setCalling(i.id)}>Take a call</button>
            {made.length > 0 && <div style={{ fontSize: 11.5, marginTop: 4 }}>
              {made.slice(-3).map((c: any) => (
                <div key={c.id} className="muted">
                  {new Date(c.at).toLocaleTimeString('en-NZ', { hour: '2-digit', minute: '2-digit', hour12: false, timeZone: 'Pacific/Auckland' })} {c.words}
                  <button className="linkish" title="Remove this call" onClick={() => undoCall(c.id)}> ×</button>
                </div>
              ))}
            </div>}
          </>;
        }} />
        <p className="muted" style={{ fontSize: 13, margin: '10px 0 0' }}>Every trip with a time to be back by is watched. Take as many calls through the day as come in — only "Back at base" closes the trip. 10 minutes past the due time it turns yellow, 20 minutes past it turns red.</p>
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

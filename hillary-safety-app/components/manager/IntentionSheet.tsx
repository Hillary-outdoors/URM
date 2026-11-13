'use client';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { SAFE, PLAN_QUICK, AIM_QUICK, needsCall, lateMinutes, lateLevel, loadChecks, issues, nzToday, nzNow, fd, hm, Checks } from '@/lib/util';
import { Pill, Picker, Quick, Matrix } from '@/components/ui';

const active = (base: any) => base.instructors.filter((p: any) => p.account_type === 'instructor' && p.employment !== 'Past staff');
const pOpts = (base: any) => active(base).map((p: any) => ({ id: p.id, label: p.name + (p.centre_id ? ' · ' + (base.centres.find((c: any) => c.id === p.centre_id)?.name || '') : '') }));
const aOpts = (base: any) => base.activities.filter((a: any) => a.active).map((a: any) => ({ id: a.id, label: a.name }));

/** Write the two link tables for an intention (replace what was there). */
async function saveLinks(id: number, who: string[], acts: number[]) {
  await supabase.from('intention_instructors').delete().eq('intention_id', id);
  await supabase.from('intention_activities').delete().eq('intention_id', id);
  const a = await supabase.from('intention_instructors').insert(who.map((w) => ({ intention_id: id, instructor_id: w })));
  const b = await supabase.from('intention_activities').insert(acts.map((x) => ({ intention_id: id, act_id: x })));
  return a.error || b.error;
}

/** Add a line to that day's "DM judgements and discussions". */
async function noteOnDaySheet(date: string, centre_id: number, line: string, replaceWith?: string) {
  const { data } = await supabase.from('dm_day_logs').select('id,dm_judgements').eq('date', date).eq('centre_id', centre_id).maybeSingle();
  const cur = replaceWith !== undefined ? replaceWith : data?.dm_judgements || '';
  const text = line ? (cur.trim() ? cur.trim() + '\n' : '') + line : cur;
  if (data) await supabase.from('dm_day_logs').update({ dm_judgements: text }).eq('id', data.id);
  else await supabase.from('dm_day_logs').insert({ date, centre_id, dm_judgements: text });
}

/** Open one intention: see it, change any part of it, approve it, log calls. */
export function IntentionSheet({ intention: i, base, onDone }: { intention: any; base: any; onDone: () => void }) {
  const [d, setD] = useState<any>({ who: i.who, acts: i.acts, overnight: i.overnight, started_at: hm(i.started_at), due_by: hm(i.due_by), pax: i.pax ?? '', outcome_of_day: i.outcome_of_day || '', plan: i.plan || '', group_name: i.group_name || '', dm_notes: i.dm_notes || '', briefed: i.briefed });
  const [judge, setJudge] = useState(''); const [judge0, setJudge0] = useState('');
  const [checks, setChecks] = useState<Checks>({ comp: {}, amp: {} }); const [comms, setComms] = useState<any[]>([]); const [err, setErr] = useState('');
  const set = (k: string, v: any) => setD((x: any) => ({ ...x, [k]: v }));
  const nm = (id: string) => base.instructors.find((x: any) => x.id === id)?.name || '?';
  const an = (id: number) => base.activities.find((x: any) => x.id === id)?.name || '?';

  useEffect(() => { loadChecks(d.who, d.acts).then(setChecks); }, [d.who, d.acts]);
  useEffect(() => {
    supabase.from('dm_day_logs').select('dm_judgements').eq('date', i.date).eq('centre_id', i.centre_id).maybeSingle().then(({ data }) => { setJudge(data?.dm_judgements || ''); setJudge0(data?.dm_judgements || ''); });
    supabase.from('comms_log').select('*').eq('date', i.date).eq('centre_id', i.centre_id).in('instructor_id', i.who.length ? i.who : ['00000000-0000-0000-0000-000000000000']).order('time').then(({ data }) => setComms(data || []));
  }, [i]);

  const need = needsCall(d, base.activities), open = i.status !== 'Closed', is = issues(d, checks, base.instructors, base.activities);
  const late = lateMinutes(i, base.activities), lv = lateLevel(late);

  function diffs() {
    const o: string[] = [], c = (n: string, x: any, y: any) => { if (String(x ?? '') !== String(y ?? '')) o.push(`${n} ${x || 'blank'} → ${y || 'blank'}`); };
    c('instructors', [...i.who].map(nm).sort().join(' + '), [...d.who].map(nm).sort().join(' + '));
    c('activities', [...i.acts].map(an).sort().join(' + '), [...d.acts].map(an).sort().join(' + '));
    c('overnight', i.overnight ? 'yes' : 'no', d.overnight ? 'yes' : 'no');
    c('started', hm(i.started_at), d.started_at); c('due', hm(i.due_by), need ? d.due_by : '');
    c('participants', i.pax, d.pax); c('outcome of the day', i.outcome_of_day, d.outcome_of_day); c('plan', i.plan, d.plan);
    return o;
  }
  async function save(extra: any = {}) {
    if (!d.who.length || !d.acts.length) { setErr('An intention needs at least one instructor and one activity.'); return false; }
    const df = diffs();
    const { error } = await supabase.from('intentions').update({
      overnight: d.overnight, started_at: need ? d.started_at || null : null, due_by: need ? d.due_by || null : null, pax: d.pax === '' ? null : +d.pax,
      outcome_of_day: d.outcome_of_day, plan: d.plan, group_name: d.group_name, dm_notes: d.dm_notes, briefed: d.briefed, ...extra,
    }).eq('id', i.id);
    if (error) { setErr(error.message); return false; }
    if (String([...i.who].sort()) !== String([...d.who].sort()) || String([...i.acts].sort()) !== String([...d.acts].sort())) {
      const e2 = await saveLinks(i.id, d.who, d.acts); if (e2) { setErr(e2.message); return false; }
    }
    // What changed is noted on the day sheet automatically. No reason box.
    const line = df.length ? `${nzNow()} ${i.who.map((w: string) => nm(w).split(' ')[0]).join(' + ')}: ${df.join('; ')}` : '';
    if (line || judge !== judge0) await noteOnDaySheet(i.date, i.centre_id, line, judge !== judge0 ? judge : undefined);
    return true;
  }
  const act = async (extra?: any) => { if (await save(extra)) onDone(); };
  async function callIn(as: string) {
    if (!(await save())) return;
    const { error } = await supabase.rpc('call_in_safe', { p_intention: i.id, p_as: as });
    if (error) setErr(error.message); else onDone();
  }

  return (
    <>
      <button className="back" onClick={onDone}>‹ Back</button>
      <h3>{i.who.map(nm).join(' + ') || 'No instructor'}</h3>
      <div className="rowflex">
        <Pill kind={i.status === 'Waiting' ? 'warn' : i.status === 'Approved' ? 'good' : 'mute'}>{i.status}</Pill>
        <Pill kind={is.length ? 'bad' : 'good'}>{is.length ? is.length + ' to check' : 'Paperwork all clear'}</Pill>
        {lv > 0 && <Pill kind={lv === 2 ? 'bad' : 'warn'}>{lv === 2 ? 'Red' : 'Yellow'} · {late} min overdue</Pill>}
        {i.entered_late && <Pill>Entered later</Pill>}
      </div>
      <dl className="facts">
        <dt>Date</dt><dd>{fd(i.date)} · {base.centres.find((c: any) => c.id === i.centre_id)?.name}</dd>
        {i.called_in_at && <><dt>Called in</dt><dd>{i.called_in_as} at {hm(i.called_in_at)}</dd></>}
        {i.debrief_notes && <><dt>Notes after the day</dt><dd>{i.debrief_notes}</dd></>}
      </dl>
      <h3 style={{ fontSize: 15, marginTop: 10 }}>The plan</h3>
      <small className="muted">Change anything here and save. What changed is noted on the day sheet under DM judgements and discussions.</small>
      <label className="f">Instructors</label><Picker options={pOpts(base)} value={d.who} onChange={(v) => set('who', v)} placeholder="Search for an instructor…" />
      <label className="f">Activities</label><Picker options={aOpts(base)} value={d.acts} onChange={(v) => set('acts', v)} placeholder="Search for an activity…" />
      <div className="check"><input type="checkbox" id="eov" checked={d.overnight} onChange={(e) => set('overnight', e.target.checked)} style={{ width: 18, height: 18 }} /><label htmlFor="eov">Overnight trip</label></div>
      {need ? (
        <div className="grid2">
          <div><label className="f" htmlFor="es">Started (logged when they call)</label><input id="es" type="time" value={d.started_at} onChange={(e) => set('started_at', e.target.value)} /></div>
          <div><label className="f" htmlFor="ee">Due out or back by</label><input id="ee" type="time" value={d.due_by} onChange={(e) => set('due_by', e.target.value)} /></div>
        </div>
      ) : <small className="muted">No call-in or times needed for these activities.</small>}
      <div className="grid2">
        <div><label className="f" htmlFor="ep">Participants</label><input id="ep" type="number" value={d.pax} onChange={(e) => set('pax', e.target.value)} /></div>
        <div><label className="f" htmlFor="eg">Group</label><input id="eg" type="text" value={d.group_name} onChange={(e) => set('group_name', e.target.value)} /></div>
      </div>
      <label className="f" htmlFor="ea">Outcome of the day</label><input id="ea" type="text" value={d.outcome_of_day} onChange={(e) => set('outcome_of_day', e.target.value)} />
      <label className="f" htmlFor="epl">Plan or route</label><textarea id="epl" rows={2} value={d.plan} onChange={(e) => set('plan', e.target.value)} />
      {!!is.length && <div className="inc"><b>To check</b>{is.map((x) => <div key={x}>{x}</div>)}</div>}
      <div style={{ marginTop: 10 }}><Matrix who={d.who.map((w: string) => ({ id: w, name: nm(w) }))} acts={d.acts.map((a: number) => ({ id: a, name: an(a) }))} checks={checks} /></div>
      <div className="check" style={{ marginTop: 10 }}><input type="checkbox" id="eb" checked={d.briefed} onChange={(e) => set('briefed', e.target.checked)} style={{ width: 18, height: 18 }} /><label htmlFor="eb">Briefed by DM</label></div>
      <label className="f" htmlFor="en">DM notes on this intention</label><textarea id="en" rows={2} value={d.dm_notes} onChange={(e) => set('dm_notes', e.target.value)} />
      <label className="f" htmlFor="ej">DM judgements and discussions (day sheet, {fd(i.date)})</label><textarea id="ej" rows={3} value={judge} onChange={(e) => setJudge(e.target.value)} />
      <div className="msg bad">{err}</div>
      <div className="rowflex">
        <button className="btn primary" onClick={() => act()}>Save changes</button>
        {i.status === 'Waiting' && <button className="btn" onClick={() => act({ status: 'Approved' })}>Approve</button>}
      </div>
      {open && (need ? (
        <><label className="f" style={{ marginTop: 14 }}>Calls</label>
          <div className="rowflex">
            {!i.started_at && <button className="btn small primary" onClick={() => { set('started_at', nzNow()); act({ started_at: nzNow() }); }}>Log start now</button>}
            {SAFE.map((s) => <button key={s} className="btn small" onClick={() => callIn(s)}>{s}</button>)}
          </div></>
      ) : <div style={{ marginTop: 14 }}><button className="btn small" onClick={() => callIn('Day finished')}>Close this intention</button></div>)}
      <h3 style={{ fontSize: 15, margin: '18px 0 4px' }}>Comms</h3>
      {comms.length ? comms.map((c) => <div className="thread" key={c.id}><small>{hm(c.time)} · {nm(c.instructor_id)}</small>{c.entry}</div>) : <small className="muted">No comms logged for these instructors.</small>}
    </>
  );
}

/** Add an intention for an instructor, today or for a day that has passed. */
export function AddIntention({ base, centreId, onDone }: { base: any; centreId: number; onDone: (date?: string) => void }) {
  const today = nzToday();
  const [d, setD] = useState<any>({ date: today, who: [], acts: [], overnight: false, started_at: '', due_by: '15:00', pax: '12', outcome_of_day: '', plan: '', group_name: '' });
  const [checks, setChecks] = useState<Checks>({ comp: {}, amp: {} }); const [err, setErr] = useState(''); const [busy, setBusy] = useState(false);
  const set = (k: string, v: any) => setD((x: any) => ({ ...x, [k]: v }));
  useEffect(() => { loadChecks(d.who, d.acts).then(setChecks); }, [d.who, d.acts]);
  const past = d.date < today, need = needsCall(d, base.activities);
  const nm = (id: string) => base.instructors.find((x: any) => x.id === id)?.name || '?';
  const an = (id: number) => base.activities.find((x: any) => x.id === id)?.name || '?';

  async function save() {
    if (!d.who.length || !d.acts.length) return setErr('Add at least one instructor and one activity.');
    setBusy(true);
    const row: any = {
      centre_id: centreId, date: d.date, overnight: d.overnight, pax: d.pax === '' ? null : +d.pax, outcome_of_day: d.outcome_of_day, plan: d.plan, group_name: d.group_name,
      due_by: need ? d.due_by || null : null, dm_notes: 'Entered by manager',
    };
    if (past) Object.assign(row, { status: 'Closed', entered_late: true, briefed: true, started_at: need ? d.started_at || null : null, called_in_at: need ? d.due_by || null : null, called_in_as: need ? 'Back at base' : 'Day finished' });
    const { data, error } = await supabase.from('intentions').insert(row).select('id').single();
    const e2 = error || (await saveLinks(data!.id, d.who, d.acts));
    setBusy(false);
    if (e2) return setErr(e2.message);
    onDone(past ? d.date : undefined);
  }

  return (
    <>
      <button className="back" onClick={() => onDone()}>‹ Back</button>
      <h3>Add intention</h3>
      <p className="muted" style={{ margin: 0 }}>For a DM entering a plan for an instructor, or catching up after a day offline.</p>
      <label className="f" htmlFor="nd">Date</label><input id="nd" type="date" max={today} value={d.date} onChange={(e) => set('date', e.target.value || today)} />
      {past && <div className="hl">This date has passed. It will be saved straight into Intention history, marked "Entered later".</div>}
      <label className="f">Instructors</label><Picker options={pOpts(base)} value={d.who} onChange={(v) => set('who', v)} placeholder="Search for an instructor…" />
      <label className="f">Activities</label><Picker options={aOpts(base)} value={d.acts} onChange={(v) => set('acts', v)} placeholder="Search for an activity…" />
      <div style={{ marginTop: 10 }}><Matrix who={d.who.map((w: string) => ({ id: w, name: nm(w) }))} acts={d.acts.map((a: number) => ({ id: a, name: an(a) }))} checks={checks} /></div>
      <div className="check"><input type="checkbox" id="nov" checked={d.overnight} onChange={(e) => set('overnight', e.target.checked)} style={{ width: 18, height: 18 }} /><label htmlFor="nov">Overnight trip</label></div>
      {need && (
        <div className="grid2">
          {past && <div><label className="f" htmlFor="ns">Started</label><input id="ns" type="time" value={d.started_at} onChange={(e) => set('started_at', e.target.value)} /></div>}
          <div><label className="f" htmlFor="ne">{past ? 'Called in at' : 'Due out or back by'}</label><input id="ne" type="time" value={d.due_by} onChange={(e) => set('due_by', e.target.value)} /></div>
        </div>
      )}
      <div className="grid2">
        <div><label className="f" htmlFor="np">Participants</label><input id="np" type="number" value={d.pax} onChange={(e) => set('pax', e.target.value)} /></div>
        <div><label className="f" htmlFor="ng">Group</label><input id="ng" type="text" value={d.group_name} onChange={(e) => set('group_name', e.target.value)} /></div>
      </div>
      <label className="f" htmlFor="na">Outcome of the day</label><input id="na" type="text" value={d.outcome_of_day} onChange={(e) => set('outcome_of_day', e.target.value)} />
      <Quick items={AIM_QUICK} onPick={(t) => set('outcome_of_day', d.outcome_of_day.trim() ? d.outcome_of_day.trim() + ', ' + t : t)} />
      <label className="f" htmlFor="npl">Plan</label><textarea id="npl" rows={2} value={d.plan} onChange={(e) => set('plan', e.target.value)} />
      <Quick items={PLAN_QUICK} onPick={(t) => set('plan', d.plan.trim() ? d.plan.trim() + ' – ' + t : t)} />
      <div className="msg bad">{err}</div>
      <button className="btn primary" disabled={busy} onClick={save}>{past ? 'Save to history' : 'Add to board'}</button>
    </>
  );
}

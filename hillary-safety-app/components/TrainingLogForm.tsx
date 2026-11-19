'use client';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { nzToday } from '@/lib/util';
import { Picker, TickGrid, TICKS, tickName } from '@/components/ui';

/**
 * The training log, as a form. The same one the instructor app and the manager screen use.
 *
 * Anyone signed in can fill one in, for themselves or for anyone else. The app records who was
 * signed in when it was written, separately from the trainer named on it, so a compliance check
 * can see the difference.
 *
 * Competent ticks every box on the competency. Indirect and Direct do not guess: the trainer ticks
 * the exact boxes they observed, line by line, on the same grid as the paper form.
 */

const TRAINING_TYPE = [
  'Developing instructor observed a session.',
  'Senior instructor observed developing instructor delivering a session.',
  'Co-instruction (both instructing together).',
  'Monitoring of staff.',
  'Targeted training session.',
  'Professional discussion.',
];
const SESSION_TYPE = [
  'Assessment with Group', 'Assessment for competency with group', 'Direct Training or assessment',
  'Direct Training', 'Targeted Training', 'Observation with Group', 'Observation/Co-instruct Obs', 'Staff Entry',
];
const OUTCOME = ['Competent', 'Indirect', 'Direct', 'Monitoring Required', 'N/a'];

const blank = (me: any) => ({
  date: nzToday(), trainees: [] as string[], trainer_id: me?.id || '', comps: [] as number[],
  activity_text: '', location: '', days: '', training_type: '', session_type: '',
  outcome: '', outcome_comments: '', summary: '', how_it_went: '',
  weather_conditions: '', clients_present: '', students_aware: '', linked_to_frame: '',
  self_observation: '', dev_needs: '', feedback_given: '',
});

export default function TrainingLogForm({ me, people, comps, onDone, onCancel }: any) {
  const [f, setF] = useState<any>(blank(me));
  const [lines, setLines] = useState<any[]>([]);          // the lines of every competency named
  const [ticks, setTicks] = useState<Set<string>>(new Set());   // "lineId:box" for each box ticked
  const [busy, setBusy] = useState(false); const [err, setErr] = useState('');
  const set = (k: string, v: any) => setF((p: any) => ({ ...p, [k]: v }));
  const staff = people.filter((p: any) => p.employment !== 'Past staff');

  const willTick = ['Competent', 'Indirect', 'Direct'].includes(f.outcome);
  const byLine = ['Indirect', 'Direct'].includes(f.outcome);   // these two are ticked by hand

  // Pull in the lines whenever the named competencies change, so the grid can be drawn.
  useEffect(() => {
    if (!f.comps.length) { setLines([]); return; }
    let live = true;
    supabase.from('competency_lines')
      .select('*, competencies!inner(id, name, level, box_labels)')
      .in('comp_id', f.comps).order('comp_id').order('sort_order')
      .then(({ data, error }) => {
        if (!live) return;
        if (error) return setErr(error.message);
        setLines((data || []).filter((l: any) => !l.auto_from_amp));
      });
    return () => { live = false; };
  }, [f.comps]);

  // A box ticked against a competency that has since been removed should not be saved.
  useEffect(() => {
    setTicks((prev) => {
      const ok = new Set(lines.map((l: any) => l.id));
      const next = new Set([...prev].filter((k) => ok.has(Number(k.split(':')[0]))));
      return next.size === prev.size ? prev : next;
    });
  }, [lines]);

  const toggle = (line: any, type: string, on: boolean) => setTicks((p) => {
    const n = new Set(p); const k = line.id + ':' + type;
    if (on) n.delete(k); else n.add(k);
    return n;
  });
  /** Tick, or clear, one whole column down a competency — line by line is accurate but slow. */
  const column = (compId: number, type: string, on: boolean) => setTicks((p) => {
    const n = new Set(p);
    lines.filter((l: any) => l.comp_id === compId && l['needs_' + type])
      .forEach((l: any) => (on ? n.add(l.id + ':' + type) : n.delete(l.id + ':' + type)));
    return n;
  });

  const trainerIni = staff.find((p: any) => p.id === f.trainer_id)?.initials || '';
  const named = f.comps
    .map((id: number) => lines.find((l: any) => l.comp_id === id)?.competencies)
    .filter(Boolean);

  async function save() {
    setErr('');
    if (!f.trainees.length) return setErr('Say who the session was for.');
    if (!f.trainer_id) return setErr('Say who ran the training.');
    if (!f.outcome) return setErr('Pick an outcome.');
    if (willTick && !f.comps.length)
      return setErr('An outcome of ' + f.outcome + ' ticks boxes, so say which competency it was for.');
    if (byLine && ticks.size === 0)
      return setErr('Tick the boxes you actually observed. ' + f.outcome + ' no longer guesses them for you.');
    if ((f.summary || '').trim().length < 5) return setErr('Write a short summary of the session.');

    setBusy(true);
    const trainer = staff.find((p: any) => p.id === f.trainer_id);
    let ticked = 0;
    for (const t of f.trainees) {
      const person = staff.find((p: any) => p.id === t);
      const row: any = {
        date: f.date, instructor_id: t, trainer: trainer?.name || null, trainer_id: f.trainer_id,
        filled_by: me?.id || null, centre_id: person?.centre_id || null, source: 'app',
        days: f.days ? Number(f.days) || null : null,
        activity_text: f.activity_text.trim() || null, location: f.location.trim() || null,
        training_type: f.training_type || null, session_type: f.session_type || null,
        outcome: f.outcome, raw_outcome: f.outcome, outcome_comments: f.outcome_comments.trim() || null,
        summary: f.summary.trim() || null, how_it_went: f.how_it_went.trim() || null,
        weather_conditions: f.weather_conditions.trim() || null,
        clients_present: f.clients_present || null,
        students_aware: f.students_aware || null, linked_to_frame: f.linked_to_frame || null,
        self_observation: f.self_observation.trim() || null,
        dev_needs: f.dev_needs.trim() || null, feedback_given: f.feedback_given.trim() || null,
      };

      const { data, error } = await supabase.from('training_logs').insert(row).select('id').single();
      if (error) { setBusy(false); return setErr(error.message); }

      if (f.comps.length) {
        const { error: e2 } = await supabase.from('training_log_comps')
          .insert(f.comps.map((c: number) => ({ log_id: data.id, comp_id: c })));
        if (e2) { setBusy(false); return setErr(e2.message); }
      }
      // Exactly which boxes, so applying it does not have to infer anything.
      if (byLine && ticks.size) {
        const rows = [...ticks].map((k) => {
          const [line_id, tick_type] = k.split(':');
          return { log_id: data.id, line_id: Number(line_id), tick_type };
        });
        const { error: e4 } = await supabase.from('training_log_ticks').insert(rows);
        if (e4) { setBusy(false); return setErr(e4.message); }
      }

      const { data: n, error: e3 } = await supabase.rpc('apply_one_training_log', { p_log: data.id });
      if (e3) { setBusy(false); return setErr(e3.message); }
      ticked += n || 0;
    }
    setBusy(false);
    onDone?.(`Saved ${f.trainees.length} entr${f.trainees.length === 1 ? 'y' : 'ies'}. ${ticked} boxes ticked.`);
    setF(blank(me)); setTicks(new Set());
  }

  const area = (k: string, label: string, rows = 2) => (
    <><label className="f" htmlFor={'tl-' + k}>{label}</label>
      <textarea id={'tl-' + k} rows={rows} value={f[k]} onChange={(e) => set(k, e.target.value)} /></>
  );
  const yesno = (k: string, label: string, extra?: string[]) => (
    <div><label className="f" htmlFor={'tl-' + k}>{label}</label>
      <select id={'tl-' + k} value={f[k]} onChange={(e) => set(k, e.target.value)}>
        <option value="">—</option><option value="Yes">Yes</option><option value="No">No</option>
        {(extra || []).map((x) => <option key={x} value={x}>{x}</option>)}
      </select></div>
  );

  return (
    <div className="card" style={{ maxWidth: 820 }}>
      <h3>Record a training session</h3>
      <p className="muted" style={{ fontSize: 13.5 }}>
        You can fill this in for yourself or for anyone else. It records that you wrote it. Competent
        ticks every box on the competency. Indirect and Direct ask you to tick the boxes you actually
        observed, line by line. It can all be undone.
      </p>

      <div className="grid2">
        <div><label className="f" htmlFor="tld">Date</label>
          <input id="tld" type="date" value={f.date} onChange={(e) => set('date', e.target.value)} /></div>
        <div><label className="f" htmlFor="tlv">Number of days</label>
          <input id="tlv" type="number" step="0.5" min="0" value={f.days} onChange={(e) => set('days', e.target.value)} /></div>
      </div>

      <label className="f">Who the training was for</label>
      <Picker options={staff.map((p: any) => ({ id: p.id, label: p.name }))} value={f.trainees}
        onChange={(v: string[]) => set('trainees', v)} placeholder="Search for the instructor…" />
      <small className="muted">Pick more than one and each gets their own entry, with the same boxes ticked.</small>

      <label className="f">Who ran the training</label>
      <Picker single options={staff.map((p: any) => ({ id: p.id, label: p.name + (p.initials ? ' (' + p.initials + ')' : '') }))}
        value={f.trainer_id ? [f.trainer_id] : []} onChange={(v: string[]) => set('trainer_id', v[0] || '')}
        placeholder="Search for the trainer…" />

      <div className="grid2">
        <div><label className="f" htmlFor="tla">Activity or pursuit</label>
          <input id="tla" type="text" value={f.activity_text} onChange={(e) => set('activity_text', e.target.value)} placeholder="Rock, Bush, High Ropes…" /></div>
        <div><label className="f" htmlFor="tll">Location</label>
          <input id="tll" type="text" value={f.location} onChange={(e) => set('location', e.target.value)} /></div>
      </div>

      <div className="grid2">
        <div><label className="f" htmlFor="tlt">Training type</label>
          <select id="tlt" value={f.training_type} onChange={(e) => set('training_type', e.target.value)}>
            <option value="">—</option>{TRAINING_TYPE.map((x) => <option key={x} value={x}>{x}</option>)}</select></div>
        <div><label className="f" htmlFor="tls">Type of session</label>
          <select id="tls" value={f.session_type} onChange={(e) => set('session_type', e.target.value)}>
            <option value="">—</option>{SESSION_TYPE.map((x) => <option key={x} value={x}>{x}</option>)}</select></div>
      </div>

      <label className="f" htmlFor="tlo">Outcome</label>
      <select id="tlo" value={f.outcome} onChange={(e) => set('outcome', e.target.value)}>
        <option value="">—</option>{OUTCOME.map((x) => <option key={x} value={x}>{x}</option>)}</select>

      <label className="f">Competency observed or assessed{willTick ? '' : ' (optional)'}</label>
      <Picker options={comps.map((c: any) => ({ id: c.id, label: c.name + ' L' + c.level }))} value={f.comps}
        onChange={(v: number[]) => set('comps', v)} placeholder="Search for the competency…" />
      <small className="muted">Name the competency itself, not the activity — that is what gets ticked.</small>

      {f.outcome === 'Competent' && f.comps.length > 0 && <div className="hl" style={{ marginTop: 8 }}>
        Competent ticks every box on {f.comps.length === 1 ? 'that competency' : 'those ' + f.comps.length + ' competencies'} for {f.trainees.length || 'each'} {f.trainees.length === 1 ? 'person' : 'people'}.
      </div>}

      {byLine && f.comps.length > 0 && (
        <div style={{ marginTop: 10 }}>
          <h3 style={{ fontSize: 15, marginBottom: 2 }}>Which boxes did you observe?</h3>
          <p className="muted" style={{ fontSize: 13, marginTop: 0 }}>
            Tick only what you saw. Grey boxes are not on the paper form for that line.
            {ticks.size > 0 && <> <b>{ticks.size} ticked.</b></>}
          </p>
          {named.map((c: any) => {
            const mine = lines.filter((l: any) => l.comp_id === c.id);
            const used = TICKS.filter((t) => mine.some((l: any) => l['needs_' + t]));
            return (
              <div key={c.id} className="card" style={{ margin: '0 0 10px' }}>
                <div className="rowflex" style={{ justifyContent: 'space-between', alignItems: 'baseline', flexWrap: 'wrap', gap: 6 }}>
                  <b style={{ fontSize: 14 }}>{c.name} L{c.level}</b>
                  <div className="rowflex" style={{ gap: 4, flexWrap: 'wrap' }}>
                    {used.map((t) => (
                      <button type="button" key={t} className="btn small" onClick={() => column(c.id, t, true)}>
                        All {tickName(t, c.box_labels)}
                      </button>
                    ))}
                    <button type="button" className="btn small" onClick={() => used.forEach((t) => column(c.id, t, false))}>Clear</button>
                  </div>
                </div>
                <TickGrid lines={mine} labels={c.box_labels}
                  has={(l: any, t: string) => ticks.has(l.id + ':' + t)}
                  canClick={() => true} onClick={toggle}
                  ini={() => trainerIni}
                  hint={(l: any, t: string) => tickName(t, c.box_labels)} />
              </div>
            );
          })}
        </div>
      )}

      <label className="f" htmlFor="tloc">Comments on the outcome</label>
      <input id="tloc" type="text" value={f.outcome_comments} onChange={(e) => set('outcome_comments', e.target.value)} />

      {area('summary', 'Summary of the session', 3)}
      {area('how_it_went', 'How the session went', 4)}
      {area('weather_conditions', 'Weather and environmental conditions')}

      <div className="grid2">
        {yesno('clients_present', 'Clients present during the session')}
        {yesno('linked_to_frame', 'Linked to the daily frame', ['Not applicable'])}
      </div>
      {yesno('students_aware', 'Students knew the objective and it suited them')}

      <h3 style={{ marginTop: 16 }}>Where next</h3>
      {area('self_observation', 'The instructor’s own reflection')}
      {area('dev_needs', 'Developmental needs identified')}
      {area('feedback_given', 'Feedback given and next steps', 3)}

      <div className="msg bad">{err}</div>
      <div className="rowflex" style={{ marginTop: 12 }}>
        <button className="btn primary" disabled={busy} onClick={save}>{busy ? 'Saving…' : 'Save the session'}</button>
        {onCancel && <button className="btn" disabled={busy} onClick={onCancel}>Cancel</button>}
      </div>
    </div>
  );
}

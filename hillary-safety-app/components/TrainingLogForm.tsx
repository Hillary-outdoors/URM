'use client';
import { useState } from 'react';
import { supabase } from '@/lib/supabase';
import { nzToday } from '@/lib/util';
import { Picker } from '@/components/ui';

/**
 * The training log, as a form. The same one the instructor app and the manager screen use.
 *
 * Anyone signed in can fill one in, for themselves or for anyone else. The app records who was
 * signed in when it was written, separately from the trainer named on it, so a compliance check
 * can see the difference. Saving it ticks the boxes for the competencies it names.
 */

const TRAINING_TYPE = [
  'Senior instructor observed developing instructor delivering a session.',
  'Targeted training session.',
  'Monitoring of staff.',
  'Co-instruction (both instructing together).',
  'Developing instructor observed a session.',
  'Professional discussion.',
];
const SESSION_TYPE = [
  'Assessment with Group', 'Assessment for competency with group', 'Direct Training or assessment',
  'Direct Training', 'Targeted Training', 'Observation with Group', 'Observation/Co-instruct Obs', 'Staff Entry',
];
const OUTCOME = ['Competent', 'Indirect', 'Direct', 'Monitoring Required', 'N/a'];
const CLIENT_GROUP = [
  'School Group - Primary/Intermediate', 'School Group - Intermediate', 'School Group - Yr 8/9',
  'School Group - Yr 10/11', 'School Group - Yr 12/13', 'School Group - Senior',
  'Certificate Students', 'Holiday Program', 'Staff only',
];
const FOLDER = ['Yes', 'No - I have emailed the training manager to do this', 'Not applicable'];
const SCORES: [string, string][] = [
  ['quality', 'Overall feel and quality of the session'],
  ['planning', 'Planning and preparation'],
  ['brief', 'Brief (safety, objectives, activity)'],
  ['education', 'Education'],
  ['wellbeing', 'Student wellbeing'],
  ['cultural', 'Cultural awareness'],
  ['group_mgmt', 'Group management'],
  ['skills', 'Instruction of skills'],
  ['debrief', 'Debrief and effectiveness'],
];

const blank = (me: any) => ({
  date: nzToday(), trainees: [] as string[], trainer_id: me?.id || '', comps: [] as number[],
  activity_text: '', location: '', days: '', training_type: '', session_type: '',
  outcome: '', outcome_comments: '', session_objectives: '', summary: '',
  sms_ok: 'Yes', sms_comments: '', students_aware: '', linked_to_frame: '',
  client_group: '', training_context: '', dev_needs: '', feedback_given: '', next_steps: '',
  folder_updated: '', self_observation: '',
  scores: {} as Record<string, number>, notes: {} as Record<string, string>,
});

function Score({ label, value, note, onScore, onNote }: any) {
  return (
    <div style={{ marginBottom: 10 }}>
      <label className="f" style={{ marginBottom: 4 }}>{label}</label>
      <div className="rowflex" style={{ gap: 6, alignItems: 'center' }}>
        {[1, 2, 3, 4, 5].map((n) => (
          <button key={n} type="button" className={'btn small' + (value === n ? ' primary' : '')}
            style={{ minWidth: 38 }} onClick={() => onScore(value === n ? undefined : n)}>{n}</button>
        ))}
        <input type="text" placeholder="Comment (optional)" style={{ flex: 1, minWidth: 140 }}
          value={note || ''} onChange={(e) => onNote(e.target.value)} />
      </div>
    </div>
  );
}

export default function TrainingLogForm({ me, people, comps, onDone, onCancel }: any) {
  const [f, setF] = useState<any>(blank(me));
  const [busy, setBusy] = useState(false); const [err, setErr] = useState('');
  const set = (k: string, v: any) => setF((p: any) => ({ ...p, [k]: v }));
  const staff = people.filter((p: any) => p.employment !== 'Past staff');

  async function save() {
    setErr('');
    if (!f.trainees.length) return setErr('Say who the session was for.');
    if (!f.trainer_id) return setErr('Say who ran the training.');
    if (!f.outcome) return setErr('Pick an outcome.');
    if (['Competent', 'Indirect', 'Direct'].includes(f.outcome) && !f.comps.length)
      return setErr('An outcome of ' + f.outcome + ' ticks boxes, so say which competency it was for.');
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
        session_objectives: f.session_objectives.trim() || null, summary: f.summary.trim() || null,
        self_observation: f.self_observation.trim() || null,
        sms_ok: f.sms_ok || null, sms_comments: f.sms_comments.trim() || null,
        students_aware: f.students_aware || null, linked_to_frame: f.linked_to_frame || null,
        client_group: f.client_group || null, training_context: f.training_context || null,
        dev_needs: f.dev_needs.trim() || null, feedback_given: f.feedback_given.trim() || null,
        next_steps: f.next_steps.trim() || null, folder_updated: f.folder_updated || null,
      };
      SCORES.forEach(([k]) => { row['score_' + k] = f.scores[k] ?? null; row['notes_' + k] = (f.notes[k] || '').trim() || null; });

      const { data, error } = await supabase.from('training_logs').insert(row).select('id').single();
      if (error) { setBusy(false); return setErr(error.message); }
      if (f.comps.length) {
        const { error: e2 } = await supabase.from('training_log_comps')
          .insert(f.comps.map((c: number) => ({ log_id: data.id, comp_id: c })));
        if (e2) { setBusy(false); return setErr(e2.message); }
      }
      const { data: n, error: e3 } = await supabase.rpc('apply_one_training_log', { p_log: data.id });
      if (e3) { setBusy(false); return setErr(e3.message); }
      ticked += n || 0;
    }
    setBusy(false);
    onDone?.(`Saved ${f.trainees.length} entr${f.trainees.length === 1 ? 'y' : 'ies'}. ${ticked} boxes ticked.`);
    setF(blank(me));
  }

  const willTick = ['Competent', 'Indirect', 'Direct'].includes(f.outcome);

  return (
    <div className="card" style={{ maxWidth: 760 }}>
      <h3>Record a training session</h3>
      <p className="muted" style={{ fontSize: 13.5 }}>
        You can fill this in for yourself or for anyone else. It records that you wrote it. Saying
        Competent, Indirect or Direct ticks the boxes for the competency you name — Competent ticks
        every box, Indirect the Self and Observation boxes, Direct the Self box. It can be undone.
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
      <small className="muted">Pick more than one and each gets their own entry.</small>

      <label className="f">Who ran the training</label>
      <Picker single options={staff.map((p: any) => ({ id: p.id, label: p.name + (p.initials ? ' (' + p.initials + ')' : '') }))}
        value={f.trainer_id ? [f.trainer_id] : []} onChange={(v: string[]) => set('trainer_id', v[0] || '')}
        placeholder="Search for the trainer…" />

      <label className="f">Competency observed or assessed{willTick ? '' : ' (optional)'}</label>
      <Picker options={comps.map((c: any) => ({ id: c.id, label: c.name + ' L' + c.level }))} value={f.comps}
        onChange={(v: number[]) => set('comps', v)} placeholder="Search for the competency…" />
      <small className="muted">Name the competency itself, not the activity — that is what gets ticked.</small>

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
      {willTick && f.comps.length > 0 && <div className="hl" style={{ marginTop: 6 }}>
        This will tick {f.outcome === 'Competent' ? 'every box' : f.outcome === 'Indirect' ? 'the Self and Observation boxes' : 'the Self box'} on {f.comps.length === 1 ? 'that competency' : 'those ' + f.comps.length + ' competencies'} for {f.trainees.length || 'each'} {f.trainees.length === 1 ? 'person' : 'people'}.
      </div>}
      <label className="f" htmlFor="tloc">Comments on the outcome</label>
      <input id="tloc" type="text" value={f.outcome_comments} onChange={(e) => set('outcome_comments', e.target.value)} />

      <label className="f" htmlFor="tlob">Session objectives</label>
      <textarea id="tlob" rows={2} value={f.session_objectives} onChange={(e) => set('session_objectives', e.target.value)} />

      <label className="f" htmlFor="tlsu">Summary of the session</label>
      <textarea id="tlsu" rows={3} value={f.summary} onChange={(e) => set('summary', e.target.value)} />

      <h3 style={{ marginTop: 16 }}>Safety</h3>
      <div className="grid2">
        <div><label className="f" htmlFor="tlsm">Followed the SMS and managed hazards</label>
          <select id="tlsm" value={f.sms_ok} onChange={(e) => set('sms_ok', e.target.value)}>
            <option value="Yes">Yes</option><option value="No">No</option></select></div>
        <div><label className="f" htmlFor="tlsc">Comments on hazards and the SMS</label>
          <input id="tlsc" type="text" value={f.sms_comments} onChange={(e) => set('sms_comments', e.target.value)} /></div>
      </div>

      <h3 style={{ marginTop: 16 }}>How it went, out of five</h3>
      {SCORES.map(([k, label]) => (
        <Score key={k} label={label} value={f.scores[k]} note={f.notes[k]}
          onScore={(n: number) => setF((p: any) => ({ ...p, scores: { ...p.scores, [k]: n } }))}
          onNote={(v: string) => setF((p: any) => ({ ...p, notes: { ...p.notes, [k]: v } }))} />
      ))}

      <div className="grid2">
        <div><label className="f" htmlFor="tlsa">Students knew the objective and it suited them</label>
          <select id="tlsa" value={f.students_aware} onChange={(e) => set('students_aware', e.target.value)}>
            <option value="">—</option><option value="Yes">Yes</option><option value="No">No</option></select></div>
        <div><label className="f" htmlFor="tlfr">Linked to the daily frame</label>
          <select id="tlfr" value={f.linked_to_frame} onChange={(e) => set('linked_to_frame', e.target.value)}>
            <option value="">—</option><option value="Yes">Yes</option><option value="No">No</option>
            <option value="Not applicable">Not applicable</option></select></div>
      </div>
      <div className="grid2">
        <div><label className="f" htmlFor="tlcg">Client group present</label>
          <select id="tlcg" value={f.client_group} onChange={(e) => set('client_group', e.target.value)}>
            <option value="">—</option>{CLIENT_GROUP.map((x) => <option key={x} value={x}>{x}</option>)}</select></div>
        <div><label className="f" htmlFor="tltc">Clients present during the training</label>
          <select id="tltc" value={f.training_context} onChange={(e) => set('training_context', e.target.value)}>
            <option value="">—</option><option value="Yes">Yes</option><option value="No">No</option></select></div>
      </div>

      <h3 style={{ marginTop: 16 }}>Where next</h3>
      <label className="f" htmlFor="tldn">Developmental needs identified</label>
      <textarea id="tldn" rows={2} value={f.dev_needs} onChange={(e) => set('dev_needs', e.target.value)} />
      <label className="f" htmlFor="tlfb">Feedback given</label>
      <textarea id="tlfb" rows={2} value={f.feedback_given} onChange={(e) => set('feedback_given', e.target.value)} />
      <label className="f" htmlFor="tlns">Recommended next steps</label>
      <textarea id="tlns" rows={2} value={f.next_steps} onChange={(e) => set('next_steps', e.target.value)} />
      <label className="f" htmlFor="tlfu">Folder updated</label>
      <select id="tlfu" value={f.folder_updated} onChange={(e) => set('folder_updated', e.target.value)}>
        <option value="">—</option>{FOLDER.map((x) => <option key={x} value={x}>{x}</option>)}</select>

      <div className="msg bad">{err}</div>
      <div className="rowflex" style={{ marginTop: 12 }}>
        <button className="btn primary" disabled={busy} onClick={save}>{busy ? 'Saving…' : 'Save the session'}</button>
        {onCancel && <button className="btn" disabled={busy} onClick={onCancel}>Cancel</button>}
      </div>
    </div>
  );
}

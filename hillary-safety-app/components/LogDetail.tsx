'use client';
import { useState } from 'react';
import { supabase } from '@/lib/supabase';
import { fd, STATUS } from '@/lib/util';
import { Pill } from '@/components/ui';

/**
 * One training log entry, opened up. The same component on both sides, so the manager screen and
 * the instructor app can never drift apart on what a log shows.
 *
 * The wording can be corrected by whoever wrote it, or by a manager. The outcome and the boxes it
 * ticked cannot be edited here on purpose: changing an outcome that has already ticked boxes would
 * leave the ticks saying one thing and the entry another. Undoing the entry is the way to do that,
 * and it puts the ticks back.
 */

/** The wording that can be corrected afterwards. */
export const LOG_EDIT: [string, string, boolean][] = [
  ['activity_text', 'Activity or pursuit', false], ['location', 'Location', false],
  ['outcome_comments', 'Comments on the outcome', false],
  ['summary', 'Summary of the session', true], ['how_it_went', 'How the session went', true],
  ['weather_conditions', 'Weather and environmental conditions', true],
  ['self_observation', 'The instructor’s own reflection', true],
  ['dev_needs', 'Developmental needs identified', true],
  ['feedback_given', 'Feedback given and next steps', true],
];
const PICKS: [string, string, boolean][] = [
  ['clients_present', 'Clients present during the session', false],
  ['students_aware', 'Students knew the objective and it suited them', false],
  ['linked_to_frame', 'Linked to the daily frame', true],
];
/** Shown in this order when a log has them. */
const VIEW: [string, string][] = [
  ['training_type', 'Training type'], ['session_type', 'Type of session'], ['location', 'Location'],
  ['outcome_comments', 'Comments on the outcome'], ['summary', 'Summary of the session'],
  ['how_it_went', 'How the session went'], ['weather_conditions', 'Weather and environmental conditions'],
  ['clients_present', 'Clients present'], ['students_aware', 'Students knew the objective'],
  ['linked_to_frame', 'Linked to the daily frame'],
  ['self_observation', 'The instructor’s own reflection'],
  ['dev_needs', 'Developmental needs identified'],
  ['feedback_given', 'Feedback given and next steps'],
];
/** Kept from the Smartsheet years. Shown when a log has them, never asked for again. */
const OLD: [string, string][] = [
  ['session_objectives', 'Session objectives'], ['sms_ok', 'Followed the SMS'],
  ['sms_comments', 'Comments on hazards and the SMS'], ['next_steps', 'Recommended next steps'],
  ['client_group', 'Client group present'], ['training_context', 'Clients present (old field)'],
  ['folder_updated', 'Folder updated'],
];
const SCORES: [string, string][] = [
  ['quality', 'Overall feel and quality'], ['planning', 'Planning and preparation'],
  ['brief', 'Brief'], ['education', 'Education'], ['wellbeing', 'Student wellbeing'],
  ['cultural', 'Cultural awareness'], ['group_mgmt', 'Group management'],
  ['skills', 'Instruction of skills'], ['debrief', 'Debrief and effectiveness'],
];

export default function LogDetail({ log, canEdit, subtitle, compName, onBack, onSaved, actions }: {
  log: any; canEdit?: boolean; subtitle?: string;
  compName: (id: number) => string;
  onBack: () => void; onSaved: (l: any) => void;
  /** Anything the calling screen wants beside the entry, such as the manager's Undo button. */
  actions?: React.ReactNode;
}) {
  const [sel, setSel] = useState<any>(log);
  const [edit, setEdit] = useState<any>(null);
  const [msg, setMsg] = useState<[string, string]>(['', '']);
  const [busy, setBusy] = useState(false);

  async function save() {
    setMsg(['', '']); setBusy(true);
    const patch: any = {};
    LOG_EDIT.forEach(([k]) => { patch[k] = (edit[k] || '').trim() || null; });
    PICKS.forEach(([k]) => { patch[k] = edit[k] || null; });
    const { error } = await supabase.from('training_logs').update(patch).eq('id', sel.id);
    setBusy(false);
    if (error) return setMsg(['bad', error.message]);
    const next = { ...sel, ...patch };
    setSel(next); setEdit(null); setMsg(['ok', 'Saved.']); onSaved(next);
  }

  const scores = SCORES.filter(([k]) => sel['score_' + k] != null || sel['notes_' + k]);

  return (
    <>
      <button className="back" onClick={onBack}>‹ Back to the list</button>
      <div className="card">
        <div className="rowflex" style={{ justifyContent: 'space-between', alignItems: 'baseline' }}>
          <h3 style={{ margin: 0 }}>{fd(sel.date)} · {sel.activity_text || 'Training'}</h3>
          {sel.outcome ? <Pill kind={STATUS[sel.outcome] || 'mute'}>{sel.outcome}</Pill> : null}
        </div>
        <div className="muted" style={{ fontSize: 13 }}>
          {subtitle ? subtitle + ' · ' : ''}trainer {sel.trainer || 'not named'}
          {sel.days ? ' · ' + sel.days + ' day' + (Number(sel.days) === 1 ? '' : 's') : ''}
          {sel.ticks_made ? ' · ' + sel.ticks_made + ' boxes ticked' : ''}
          {sel.applied_at ? ' · applied' : ''}
        </div>
        {(sel.training_log_comps || []).length > 0 && <div style={{ marginTop: 6 }}>
          {(sel.training_log_comps || []).map((x: any) => (
            <span key={x.comp_id} style={{ marginRight: 6 }}><Pill>{compName(x.comp_id)}</Pill></span>
          ))}
        </div>}
        {actions && <div className="rowflex" style={{ marginTop: 10 }}>{actions}</div>}
      </div>

      {!edit ? (
        <div className="card">
          <dl>
            {[...VIEW, ...OLD].filter(([k]) => sel[k]).map(([k, l]) => (
              <span key={k} style={{ display: 'contents' }}><dt>{l}</dt><dd>{sel[k]}</dd></span>
            ))}
          </dl>
          {scores.length > 0 && <>
            <label className="f">Scores out of five, from the old form</label>
            {scores.map(([k, l]) => (
              <div key={k} style={{ fontSize: 13.5 }}>
                {l}: <b>{sel['score_' + k] ?? '—'}</b>{sel['notes_' + k] ? ' · ' + sel['notes_' + k] : ''}
              </div>
            ))}
          </>}
          <div className={'msg ' + msg[0]}>{msg[1]}</div>
          {canEdit
            ? <><button className="btn" onClick={() => setEdit({ ...sel })}>Edit the wording</button>
                <p className="muted" style={{ fontSize: 12.5, margin: '8px 0 0' }}>
                  The outcome and the boxes it ticked are not edited here. To change those, undo the
                  entry — that puts the ticks back — and write it again.
                </p></>
            : <p className="muted" style={{ fontSize: 12.5, margin: 0 }}>
                Only whoever wrote this, or a manager, can change it.
              </p>}
        </div>
      ) : (
        <div className="card">
          <h3 style={{ fontSize: 15 }}>Edit the wording</h3>
          {LOG_EDIT.map(([k, label, big]) => (
            <span key={k} style={{ display: 'contents' }}>
              <label className="f" htmlFor={'ld-' + k}>{label}</label>
              {big
                ? <textarea id={'ld-' + k} rows={3} value={edit[k] || ''} onChange={(e) => setEdit({ ...edit, [k]: e.target.value })} />
                : <input id={'ld-' + k} type="text" value={edit[k] || ''} onChange={(e) => setEdit({ ...edit, [k]: e.target.value })} />}
            </span>
          ))}
          {PICKS.map(([k, label, na]) => (
            <span key={k} style={{ display: 'contents' }}>
              <label className="f" htmlFor={'ld-' + k}>{label}</label>
              <select id={'ld-' + k} value={edit[k] || ''} onChange={(e) => setEdit({ ...edit, [k]: e.target.value })}>
                <option value="">—</option><option value="Yes">Yes</option><option value="No">No</option>
                {na && <option value="Not applicable">Not applicable</option>}
              </select>
            </span>
          ))}
          <div className={'msg ' + msg[0]}>{msg[1]}</div>
          <div className="rowflex" style={{ marginTop: 10 }}>
            <button className="btn primary" disabled={busy} onClick={save}>{busy ? 'Saving…' : 'Save'}</button>
            <button className="btn" disabled={busy} onClick={() => { setEdit(null); setMsg(['', '']); }}>Cancel</button>
          </div>
        </div>
      )}
    </>
  );
}

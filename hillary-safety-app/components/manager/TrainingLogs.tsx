'use client';
import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { fd, STATUS, downloadCsv, fetchAll } from '@/lib/util';
import { Pill, Picker } from '@/components/ui';
import TrainingLogForm from '@/components/TrainingLogForm';

const dmName = () => { try { return localStorage.getItem('dmName') || ''; } catch (e) { return ''; } };

/**
 * The training log. Entries are written on the form, by anyone, about anyone, and they tick the
 * boxes for the competency they name. This screen is the manager's view of all of them, the
 * compliance check, and the export for an audit.
 */
export default function TrainingLogs({ base, reload }: any) {
  const [tab, setTab] = useState('logs');
  const [logs, setLogs] = useState<any[]>([]);
  const [who, setWho] = useState<string[]>([]);
  const [onlySelf, setOnlySelf] = useState(false);
  const [busy, setBusy] = useState(false); const [err, setErr] = useState(''); const [done, setDone] = useState('');
  const people = base.instructors.filter((p: any) => p.account_type === 'instructor');
  const me = base.me;   // the signed-in manager; the form records them as the author

  const load = useCallback(async () => {
    let q = supabase.from('training_logs')
      .select('*, training_log_comps(comp_id)')
      .order('date', { ascending: false }).limit(400);
    if (who.length) q = q.in('instructor_id', who);
    const { data } = await q;
    setLogs(data || []);
  }, [who]);
  useEffect(() => { load(); }, [load]);

  const nameOf = (id: string) => base.instructors.find((p: any) => p.id === id)?.name || '';
  const compOf = (id: number) => base.comps.find((c: any) => c.id === id);
  const shown = onlySelf ? logs.filter((l) => l.filled_by && l.filled_by === l.instructor_id) : logs;

  async function undo(log: any) {
    setBusy(true); setErr('');
    const { data, error } = await supabase.rpc('revert_training_log', { p_log: log.id });
    if (error) { setBusy(false); return setErr(error.message); }
    await supabase.from('change_log').insert({
      kind: 'Sign-off', changed_by: 'Manager · ' + (dmName() || 'unnamed'),
      what: nameOf(log.instructor_id) + ' · undid the training log entry of ' + fd(log.date) + ' — ' + data + ' boxes taken back',
      reason: 'Undone from the training log',
    });
    setBusy(false); reload?.(); load();
  }

  async function exportCsv() {
    setBusy(true); setErr('');
    try {
      const rows = await fetchAll(() => supabase.from('v_training_log_export').select('*').order('date', { ascending: false }));
      if (!rows.length) { setBusy(false); return setErr('There is nothing in the log to export yet.'); }
      // header row first, then one row per entry, in the same column order
      const cols = Object.keys(rows[0]);
      const pretty = cols.map((c) => c.replace(/_/g, ' ').replace(/^./, (m) => m.toUpperCase()));
      downloadCsv('URMA-training-log-' + new Date().toISOString().slice(0, 10) + '.csv',
        [pretty, ...rows.map((r: any) => cols.map((c) => r[c]))]);
    } catch (e: any) { setErr(e.message || 'The export failed.'); }
    setBusy(false);
  }

  return (
    <div className="mpanel">
      <div className="filters">
        <div className="seg">
          <button className={tab === 'logs' ? 'on' : ''} onClick={() => setTab('logs')}>Log entries</button>
          <button className={tab === 'new' ? 'on' : ''} onClick={() => setTab('new')}>Record a session</button>
        </div>
        {tab === 'logs' && <>
          <div style={{ minWidth: 240 }}>
            <label className="f" style={{ marginTop: 0 }}>Instructor</label>
            <Picker options={people.map((x: any) => ({ id: x.id, label: x.name }))} value={who} onChange={setWho} placeholder="Everyone" />
          </div>
          <div className="seg">
            <button className={!onlySelf ? 'on' : ''} onClick={() => setOnlySelf(false)}>All entries</button>
            <button className={onlySelf ? 'on' : ''} onClick={() => setOnlySelf(true)}>
              Compliance check ({logs.filter((l) => l.filled_by && l.filled_by === l.instructor_id).length})
            </button>
          </div>
          <button className="btn" disabled={busy} onClick={exportCsv}>Export for audit</button>
        </>}
      </div>

      {done && <div className="hl">{done}</div>}
      <div className="msg bad">{err}</div>

      {tab === 'new' && (me ? <TrainingLogForm me={me} people={people} comps={base.comps}
        onDone={(m: string) => { setDone(m); setTab('logs'); load(); reload?.(); }} />
        : <p className="muted">Loading…</p>)}

      {tab === 'logs' && (onlySelf && shown.length === 0
        ? <p className="muted">No entries were written by the person they are about. Nothing to check.</p>
        : shown.length ? <div className="scroll"><table className="m">
        <thead><tr><th>Date</th><th>Instructor</th><th>Trainer</th><th>Written by</th><th>Activity</th><th>Outcome</th><th>Ticked</th><th></th></tr></thead>
        <tbody>{shown.map((l) => {
          const comps = (l.training_log_comps || []).map((x: any) => compOf(x.comp_id)).filter(Boolean);
          const selfWritten = l.filled_by && l.filled_by === l.instructor_id;
          return <tr key={l.id}>
            <td>{fd(l.date)}</td><td><b>{nameOf(l.instructor_id)}</b></td><td>{l.trainer || ''}</td>
            <td>{l.filled_by ? (selfWritten ? <Pill kind="warn">{nameOf(l.filled_by)}</Pill> : nameOf(l.filled_by)) : <small className="muted">Smartsheet</small>}</td>
            <td>{l.activity_text || ''}{l.location ? <><br /><small className="muted">{l.location}</small></> : null}</td>
            <td>{l.outcome ? <Pill kind={STATUS[l.outcome] || 'mute'}>{l.outcome}</Pill> : ''}</td>
            <td>{comps.length
              ? <>{comps.map((c: any) => <span key={c.id} style={{ marginRight: 6 }}><Pill kind="good">{c.name} L{c.level}</Pill></span>)}
                  <small className="muted">{l.ticks_made || 0} boxes</small></>
              : <small className="muted">{['Competent', 'Indirect', 'Direct'].includes(l.outcome) ? 'nothing left to tick' : 'recorded only'}</small>}</td>
            <td>{l.ticks_made ? <button className="btn small" disabled={busy} onClick={() => undo(l)}>Undo</button> : null}</td>
          </tr>;
        })}</tbody>
      </table></div> : <p className="muted">No entries yet. Use "Record a session".</p>)}
    </div>
  );
}

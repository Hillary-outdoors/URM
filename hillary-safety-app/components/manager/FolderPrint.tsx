'use client';
import { Fragment, useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { fd, fetchAll } from '@/lib/util';
import { TICKS, tickName } from '@/components/ui';

/**
 * The competency folder, printed. One page per competency, the lines in the order they appear on
 * the paper form, and every box either empty or carrying the initials and date that went in it.
 *
 * It is built from the records at the moment you press the button, so if a competency form changes
 * the print-out changes with it — which is the point of not keeping paper.
 */
export default function FolderPrint({ person, onClose }: any) {
  const [state, setState] = useState<any>({ loading: true });
  const [err, setErr] = useState('');

  const load = useCallback(async () => {
    setState({ loading: true });
    try {
      const [st, q, ls, so] = await Promise.all([
        supabase.from('v_competency_status').select('*, competencies!inner(version,scope,prerequisites,rrcc_text,assessment_notes)')
          .eq('instructor_id', person.id).order('level').order('name'),
        supabase.from('qualifications_held').select('*').eq('instructor_id', person.id).order('qualification'),
        fetchAll(() => supabase.from('competency_lines').select('*').order('comp_id').order('sort_order').order('id')),
        fetchAll(() => supabase.from('comp_signoffs').select('line_id,tick_type,initials,signed_by,observed_on,site,source').eq('instructor_id', person.id)),
      ]);
      if (st.error) throw new Error(st.error.message);
      const ticks = new Map<string, any>();
      (so || []).forEach((s: any) => ticks.set(s.line_id + '|' + s.tick_type, s));
      const byComp = new Map<number, any[]>();
      (ls || []).forEach((l: any) => byComp.set(l.comp_id, [...(byComp.get(l.comp_id) || []), l]));
      // flatten the form's own wording up alongside the status
      const stat = (st.data || []).map((r: any) => ({ ...r, ...(r.competencies || {}) }));
      setState({ loading: false, stat, quals: q.data || [], lines: byComp, ticks });
    } catch (e: any) { setErr(e.message || 'Could not build the folder.'); setState({ loading: false }); }
  }, [person.id]);
  useEffect(() => { load(); }, [load]);

  if (state.loading) return <div className="mpanel"><p className="muted">Building the folder…</p></div>;

  const mine = (state.stat || []).filter((s: any) => !s.centre_id || !person.centre_id || s.centre_id === person.centre_id);
  const started = mine.filter((s: any) => s.status !== 'Not started');
  const notStarted = mine.filter((s: any) => s.status === 'Not started');

  return (
    <div className="takesheet">
      <div className="noprint rowflex" style={{ marginBottom: 10 }}>
        <button className="btn primary" onClick={() => window.print()}>Print</button>
        {onClose && <button className="btn" onClick={onClose}>Close</button>}
        <span className="muted" style={{ alignSelf: 'center', fontSize: 13 }}>
          {started.length} competenc{started.length === 1 ? 'y' : 'ies'} with something in them
        </span>
      </div>
      {err && <div className="msg bad">{err}</div>}

      <h2 style={{ marginBottom: 2 }}>{person.name}</h2>
      <div className="muted" style={{ fontSize: 13 }}>
        Competency folder · printed {fd(new Date().toISOString().slice(0, 10))}
        {person.employment ? ' · ' + person.employment : ''}
      </div>

      {(state.quals || []).length > 0 && <div className="card" style={{ marginTop: 10, breakInside: 'avoid' }}>
        <b style={{ fontSize: 14 }}>Qualifications held</b>
        <div style={{ marginTop: 4, fontSize: 12.5 }}>
          {state.quals.map((q: any) => (
            <div key={q.id}>{q.qualification}{q.level ? ' · ' + q.level : ''}{q.notes ? ' — ' + q.notes : ''}</div>
          ))}
        </div>
      </div>}

      <div className="card" style={{ marginTop: 10, breakInside: 'avoid' }}>
        <b style={{ fontSize: 14 }}>Where this folder stands</b>
        <div style={{ marginTop: 4, fontSize: 12.5 }}>
          {mine.length === 0 ? 'Nothing recorded.' : ['Competent', 'Indirect', 'Direct', 'Not started'].map((s) => {
            const n = mine.filter((x: any) => x.status === s).length;
            return n ? <div key={s}><b>{s}:</b> {n}</div> : null;
          })}
        </div>
      </div>

      {started.map((s: any) => {
        const lines = (state.lines.get(s.comp_id) || []).filter((l: any) => !l.auto_from_amp);
        const used = TICKS.filter((t) => lines.some((l: any) => l['needs_' + t]));
        let section = '';
        return (
          <div key={s.comp_id} className="formpage">
            {/* the head of the paper form: title, version, and the Completed/RRCC box */}
            <div className="formhead">
              <div>
                <h3 style={{ margin: 0, fontSize: 19 }}>{s.name} <span style={{ fontWeight: 400 }}>(L{s.level})</span></h3>
                {s.version && <div className="muted" style={{ fontSize: 12.5, fontStyle: 'italic' }}>{s.version}</div>}
              </div>
              <table className="rrccbox"><tbody><tr>
                <td>Completed/RRCC</td>
                <td style={{ width: 54, textAlign: 'center' }}>{s.status === 'Competent' ? 'R' : ''}</td>
              </tr></tbody></table>
            </div>

            {(s.scope || s.prerequisites || s.rrcc_text || s.assessment_notes) && (
              <div className="formboxes">
                {s.scope && <div><b>Scope</b><div>{s.scope}</div></div>}
                {s.prerequisites && <div><b>Prerequisites</b><div>{s.prerequisites}</div></div>}
                {s.rrcc_text && <div><b>Recorded Recognition of Current Competence</b><div>{s.rrcc_text}</div></div>}
                {s.assessment_notes && <div><b>Assessment</b><div>{s.assessment_notes}</div></div>}
              </div>
            )}

            <div className="muted" style={{ fontSize: 12, margin: '6px 0 4px' }}>
              {s.status} · {s.done} of {s.total} boxes{s.code ? ' · ' + s.code : ''}
            </div>

            <table className="m formtable">
              <thead><tr>
                <th>&nbsp;</th>
                {used.map((t) => <th key={t} className="boxcol">{tickName(t, s.box_labels)}</th>)}
              </tr></thead>
              <tbody>
                {lines.map((l: any) => {
                  const head = l.section && l.section !== section ? (section = l.section) : null;
                  return (
                    <Fragment key={l.id}>
                      {head && <tr className="sectionrow"><td colSpan={used.length + 1}>{head}</td></tr>}
                      <tr>
                        <td>{l.element ? <b>{l.element}: </b> : null}{l.content}</td>
                        {used.map((t) => {
                          if (!l['needs_' + t]) return <td key={t} className="notonform" />;
                          const hit = state.ticks.get(l.id + '|' + t);
                          return (
                            <td key={t} className="boxcol">
                              {hit ? <>
                                <b>{hit.initials || '✓'}</b>
                                {hit.observed_on ? <><br /><span className="tiny">{fd(hit.observed_on)}</span></> : null}
                                {hit.site ? <><br /><span className="tiny">{hit.site}</span></> : null}
                              </> : ''}
                            </td>
                          );
                        })}
                      </tr>
                    </Fragment>
                  );
                })}
              </tbody>
            </table>
          </div>
        );
      })}

      {notStarted.length > 0 && <div className="card" style={{ marginTop: 16, breakInside: 'avoid' }}>
        <b style={{ fontSize: 14 }}>Not started</b>
        <div style={{ marginTop: 4, fontSize: 12.5 }}>
          {notStarted.map((s: any) => s.name + ' L' + s.level).join(' · ')}
        </div>
      </div>}
    </div>
  );
}

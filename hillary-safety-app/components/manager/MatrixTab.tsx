'use client';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { loadRequirements } from '@/lib/util';
import { Picker, Pill, StatusPill } from '@/components/ui';

type Col = { key: string; kind: 'Competency' | 'AMP'; id: number; name: string; from?: string };

/**
 * Who can run what. One search: pick the people, then pick any mix of activities, competencies
 * and AMPs. An activity is only a shortcut — choosing one adds the competencies and AMPs it needs
 * as columns of their own, so the table always shows the same thing: does this person hold it.
 */
export default function MatrixTab({ base }: any) {
  const [who, setWho] = useState<string[]>([]);
  const [acts, setActs] = useState<number[]>([]);
  const [amps, setAmps] = useState<number[]>([]);
  const [comps, setComps] = useState<number[]>([]);
  const [cols, setCols] = useState<Col[]>([]);
  const [comp, setComp] = useState<Record<string, string>>({});
  const [amp, setAmp] = useState<Record<string, boolean>>({});
  const [note, setNote] = useState<string[]>([]);

  const people = base.instructors.filter((p: any) => p.account_type === 'instructor' && p.employment !== 'Past staff');
  // the day-sheet descriptions first, then the AMP-shaped activities
  const actOpts = [...base.activities].filter((a: any) => a.active)
    .sort((a: any, b: any) => (b.preset ? 1 : 0) - (a.preset ? 1 : 0) || a.name.localeCompare(b.name))
    .map((a: any) => ({ id: a.id, label: (a.preset ? '★ ' : '') + a.name }));
  const ampOpts = base.amps.map((m: any) => ({ id: m.id, label: m.title }));
  const compOpts = base.comps.map((c: any) => ({ id: c.id, label: `${c.name} (L${c.level})` }));

  // Work out the columns: everything picked, plus whatever the picked activities ask for.
  useEffect(() => {
    (async () => {
      const reqs = acts.length ? await loadRequirements(acts) : {};
      const out: Col[] = []; const seen = new Set<string>(); const msgs: string[] = [];
      const add = (kind: Col['kind'], id: number, name: string, from?: string) => {
        const key = kind + ':' + id;
        if (seen.has(key)) return; seen.add(key); out.push({ key, kind, id, name, from });
      };
      comps.forEach((id) => { const c = base.comps.find((x: any) => x.id === id); if (c) add('Competency', c.id, `${c.name} (L${c.level})`, 'you picked it'); });
      amps.forEach((id) => { const m = base.amps.find((x: any) => x.id === id); if (m) add('AMP', m.id, m.title, 'you picked it'); });
      for (const a of acts) {
        const an = base.activities.find((x: any) => x.id === a)?.name || 'activity';
        const r = reqs[a] || [];
        if (!r.length) msgs.push(`${an} asks for nothing yet — no AMP and no competency are linked to it.`);
        else if (!r.some((x: any) => x.kind === 'Competency' && !x.everyone)) msgs.push(`${an} has no competency of its own linked yet, so only its AMP and the competencies everyone needs are being checked.`);
        r.forEach((x: any) => add(x.kind, x.item_id, x.item_name, x.everyone ? 'everyone needs it' : 'from ' + an));
      }
      setCols(out); setNote([...new Set(msgs)]);
    })();
  }, [acts, amps, comps, base.activities, base.comps, base.amps]);

  // Look up each person against each column.
  useEffect(() => {
    (async () => {
      const cIds = cols.filter((c) => c.kind === 'Competency').map((c) => c.id);
      const mIds = cols.filter((c) => c.kind === 'AMP').map((c) => c.id);
      if (!who.length || (!cIds.length && !mIds.length)) { setComp({}); setAmp({}); return; }
      const [c, m] = await Promise.all([
        cIds.length ? supabase.from('v_competency_status').select('instructor_id,comp_id,status').in('instructor_id', who).in('comp_id', cIds).limit(20000) : Promise.resolve({ data: [] as any[] }),
        mIds.length ? supabase.from('v_amp_status').select('instructor_id,amp_id,up_to_date').in('instructor_id', who).in('amp_id', mIds).limit(20000) : Promise.resolve({ data: [] as any[] }),
      ]);
      const cm: Record<string, string> = {}; (c.data || []).forEach((x: any) => { cm[x.instructor_id + '|' + x.comp_id] = x.status; });
      const am: Record<string, boolean> = {}; (m.data || []).forEach((x: any) => { am[x.instructor_id + '|' + x.amp_id] = x.up_to_date; });
      setComp(cm); setAmp(am);
    })();
  }, [who, cols]);

  function cell(wid: string, col: Col) {
    if (col.kind === 'Competency') {
      const s = comp[wid + '|' + col.id];
      if (s === undefined) return <span className="muted" title="No row came back for this person and competency. Tell me if you see this.">—</span>;
      return <StatusPill status={s} />;
    }
    const v = amp[wid + '|' + col.id];
    if (v === undefined) return <span className="muted" title="This AMP has not been published to the app yet, so nobody can have signed it.">Not published</span>;
    return <b className={v ? 'okc' : 'noc'}>{v ? '✓ Signed' : '✗ Not signed'}</b>;
  }
  const ready = (wid: string) => cols.every((c) => c.kind === 'Competency' ? comp[wid + '|' + c.id] === 'Competent' : amp[wid + '|' + c.id] === true);

  return (
    <div className="mpanel">
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(230px,1fr))', gap: '0 16px' }}>
        <div><label className="f" style={{ marginTop: 0 }}>Instructors</label>
          <Picker options={people.map((p: any) => ({ id: p.id, label: p.name }))} value={who} onChange={setWho} placeholder="Search instructors…" /></div>
        <div><label className="f" style={{ marginTop: 0 }}>Activity <span className="muted">(a preset)</span></label>
          <Picker options={actOpts} value={acts} onChange={setActs} placeholder="O'cave, BB, SOT Tokaanu…" /></div>
        <div><label className="f" style={{ marginTop: 0 }}>AMPs</label>
          <Picker options={ampOpts} value={amps} onChange={setAmps} placeholder="Search AMPs…" /></div>
        <div><label className="f" style={{ marginTop: 0 }}>Competencies</label>
          <Picker options={compOpts} value={comps} onChange={setComps} placeholder="Search competencies…" /></div>
      </div>
      <p className="muted" style={{ fontSize: 13, margin: '8px 0 0', maxWidth: '80ch' }}>
        An activity is only a preset: picking one fills in the AMPs and competencies it stands for. For a day that is
        not on the list, leave it empty and pick the AMPs and competencies yourself.
      </p>
      {note.map((n) => <div key={n} className="inc" style={{ marginTop: 8 }}>{n}</div>)}

      <div style={{ marginTop: 14 }}>
        {who.length && cols.length ? (
          <div className="scroll">
            <table className="mx">
              <thead><tr><th></th>
                {cols.map((c) => <th key={c.key}><div>{c.name}</div><small className="muted">{c.kind}{c.from ? ' · ' + c.from : ''}</small></th>)}
                <th>All of it?</th></tr></thead>
              <tbody>
                {who.map((wid) => (
                  <tr key={wid}><th>{people.find((p: any) => p.id === wid)?.name}</th>
                    {cols.map((c) => <td key={c.key}>{cell(wid, c)}</td>)}
                    <td><b className={ready(wid) ? 'okc' : 'noc'}>{ready(wid) ? '✓ Yes' : '✗ No'}</b></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : <p className="muted">Add at least one instructor, and an activity, AMP or competency.</p>}
      </div>
      <p className="muted" style={{ fontSize: 13, margin: '10px 0 0', maxWidth: '80ch' }}>
        A competency column shows where that person is up to. An AMP column shows whether they have signed the current
        version. “All of it?” is yes only when every column on the row is satisfied.
      </p>
    </div>
  );
}

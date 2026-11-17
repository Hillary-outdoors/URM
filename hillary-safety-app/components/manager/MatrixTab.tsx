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
  const [picked, setPicked] = useState<string[]>([]);      // 'act:1' | 'comp:2' | 'amp:3'
  const [cols, setCols] = useState<Col[]>([]);
  const [comp, setComp] = useState<Record<string, string>>({});
  const [amp, setAmp] = useState<Record<string, boolean>>({});
  const [note, setNote] = useState<string[]>([]);

  const people = base.instructors.filter((p: any) => p.account_type === 'instructor' && p.employment !== 'Past staff');
  const options = [
    ...base.activities.filter((a: any) => a.active).map((a: any) => ({ id: 'act:' + a.id, label: 'Activity · ' + a.name })),
    ...base.comps.map((c: any) => ({ id: 'comp:' + c.id, label: `Competency · ${c.name} (L${c.level})` })),
    ...base.amps.map((m: any) => ({ id: 'amp:' + m.id, label: 'AMP · ' + m.title })),
  ];

  // Work out the columns: everything picked directly, plus whatever the picked activities ask for.
  useEffect(() => {
    (async () => {
      const actIds = picked.filter((p) => p.startsWith('act:')).map((p) => +p.slice(4));
      const reqs = actIds.length ? await loadRequirements(actIds) : {};
      const out: Col[] = []; const seen = new Set<string>(); const msgs: string[] = [];
      const add = (kind: Col['kind'], id: number, name: string, from?: string) => {
        const key = kind + ':' + id;
        if (seen.has(key)) return; seen.add(key); out.push({ key, kind, id, name, from });
      };
      for (const p of picked) {
        if (p.startsWith('comp:')) { const c = base.comps.find((x: any) => x.id === +p.slice(5)); if (c) add('Competency', c.id, `${c.name} (L${c.level})`, 'you picked it'); }
        if (p.startsWith('amp:')) { const m = base.amps.find((x: any) => x.id === +p.slice(4)); if (m) add('AMP', m.id, m.title, 'you picked it'); }
      }
      for (const a of actIds) {
        const an = base.activities.find((x: any) => x.id === a)?.name || 'activity';
        const r = reqs[a] || [];
        if (!r.some((x: any) => x.kind === 'Competency' && !x.everyone)) msgs.push(`${an} has no competency linked to it yet, so only the AMP and the competencies everyone needs are being checked.`);
        if (!r.length) msgs.push(`${an} asks for nothing yet — no AMP and no competency are linked to it.`);
        r.forEach((x: any) => add(x.kind, x.item_id, x.item_name, x.everyone ? 'everyone needs it' : 'from ' + an));
      }
      setCols(out); setNote([...new Set(msgs)]);
    })();
  }, [picked, base.activities, base.comps, base.amps]);

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
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(280px,1fr))', gap: '0 20px' }}>
        <div><label className="f" style={{ marginTop: 0 }}>Instructors</label>
          <Picker options={people.map((p: any) => ({ id: p.id, label: p.name }))} value={who} onChange={setWho} placeholder="Search instructors…" /></div>
        <div><label className="f" style={{ marginTop: 0 }}>Activities, competencies and AMPs</label>
          <Picker options={options} value={picked} onChange={setPicked} placeholder="Search — type cave, rock, a person's trip…" /></div>
      </div>
      <p className="muted" style={{ fontSize: 13, margin: '8px 0 0', maxWidth: '80ch' }}>
        Pick an activity as a shortcut and it adds the competencies and AMPs it needs. For a one-off day, pick the
        competencies and AMPs straight from the same box.
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
        ) : <p className="muted">Add at least one instructor and one activity, competency or AMP.</p>}
      </div>
      <p className="muted" style={{ fontSize: 13, margin: '10px 0 0', maxWidth: '80ch' }}>
        A competency column shows where that person is up to. An AMP column shows whether they have signed the current
        version. “All of it?” is yes only when every column on the row is satisfied.
      </p>
    </div>
  );
}

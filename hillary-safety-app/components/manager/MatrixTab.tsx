'use client';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { Picker, StatusPill } from '@/components/ui';

/** Who can run what: pick the people, the competencies and the AMPs, and read the grid. */
export default function MatrixTab({ base }: any) {
  const [who, setWho] = useState<string[]>([]);
  const [comps, setComps] = useState<number[]>([]);
  const [amps, setAmps] = useState<number[]>([]);
  const [cs, setCs] = useState<Record<string, string>>({});
  const [as_, setAs] = useState<Record<string, boolean>>({});
  const [busy, setBusy] = useState(false);

  const people = base.instructors.filter((p: any) => p.account_type === 'instructor' && p.employment !== 'Past staff');

  useEffect(() => {
    let off = false;
    (async () => {
      if (!who.length || (!comps.length && !amps.length)) { setCs({}); setAs({}); return; }
      setBusy(true);
      const [c, m] = await Promise.all([
        comps.length ? supabase.from('v_competency_status').select('instructor_id,comp_id,status').in('instructor_id', who).in('comp_id', comps) : Promise.resolve({ data: [] as any[] }),
        amps.length ? supabase.from('v_amp_status').select('instructor_id,amp_id,up_to_date').in('instructor_id', who).in('amp_id', amps) : Promise.resolve({ data: [] as any[] }),
      ]);
      if (off) return;
      const cm: Record<string, string> = {}; (c.data || []).forEach((x: any) => { cm[x.instructor_id + '|' + x.comp_id] = x.status; });
      const am: Record<string, boolean> = {}; (m.data || []).forEach((x: any) => { am[x.instructor_id + '|' + x.amp_id] = x.up_to_date; });
      setCs(cm); setAs(am); setBusy(false);
    })();
    return () => { off = true; };
  }, [who, comps, amps]);

  const cName = (id: number) => { const c = base.comps.find((x: any) => x.id === id); return c ? `${c.name} (L${c.level})` : '?'; };
  const aName = (id: number) => base.amps.find((x: any) => x.id === id)?.title || '?';
  const ok = (wid: string) => comps.every((id) => cs[wid + '|' + id] === 'Competent') && amps.every((id) => as_[wid + '|' + id] === true);

  return (
    <div className="mpanel">
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(240px,1fr))', gap: '0 16px' }}>
        <div><label className="f" style={{ marginTop: 0 }}>Instructors</label>
          <Picker options={people.map((p: any) => ({ id: p.id, label: p.name }))} value={who} onChange={setWho} placeholder="Search instructors…" /></div>
        <div><label className="f" style={{ marginTop: 0 }}>Competencies</label>
          <Picker options={base.comps.map((c: any) => ({ id: c.id, label: `${c.name} (L${c.level})` }))} value={comps} onChange={setComps} placeholder="Search competencies…" /></div>
        <div><label className="f" style={{ marginTop: 0 }}>AMPs</label>
          <Picker options={base.amps.map((m: any) => ({ id: m.id, label: m.title }))} value={amps} onChange={setAmps} placeholder="Search AMPs…" /></div>
      </div>

      <div style={{ marginTop: 14 }}>
        {!who.length || (!comps.length && !amps.length) ? (
          <p className="muted">Pick some people, then the competencies or AMPs you want to check.</p>
        ) : (
          <div className="scroll">
            {busy && <p className="muted">Loading…</p>}
            <table className="mx">
              <thead>
                <tr><th></th>
                  {comps.map((id) => <th key={'c' + id}>{cName(id)}</th>)}
                  {amps.map((id) => <th key={'a' + id}>{aName(id)}</th>)}
                  <th>All</th></tr>
              </thead>
              <tbody>
                {who.map((wid) => (
                  <tr key={wid}>
                    <th>{people.find((p: any) => p.id === wid)?.name}</th>
                    {comps.map((id) => <td key={'c' + id}><StatusPill status={cs[wid + '|' + id]} /></td>)}
                    {amps.map((id) => {
                      const v = as_[wid + '|' + id];
                      return <td key={'a' + id}><b className={v ? 'okc' : 'noc'}>{v === undefined ? '—' : v ? '✓' : '✗'}</b></td>;
                    })}
                    <td><b className={ok(wid) ? 'okc' : 'noc'}>{ok(wid) ? '✓' : '✗'}</b></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
      <p className="muted" style={{ fontSize: 13, margin: '10px 0 0' }}>
        AMP column: ✓ signed the current version, ✗ not signed, — not published yet.
      </p>
    </div>
  );
}

'use client';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { Picker, StatusPill } from '@/components/ui';

/**
 * The other way round: pick one competency and see where everybody stands on it. The competency
 * editor has had this all along, but people were not going in there to look.
 */
function ByCompetency({ base }: any) {
  const [pick, setPick] = useState<number[]>([]);
  const [rows, setRows] = useState<any[]>([]);
  const [busy, setBusy] = useState(false);
  const id = pick[0];

  useEffect(() => {
    let off = false;
    if (!id) { setRows([]); return; }
    setBusy(true);
    supabase.from('v_competency_status')
      .select('instructor_id,instructor_name,status,done,total')
      .eq('comp_id', id).order('instructor_name')
      .then(({ data }) => { if (!off) { setRows(data || []); setBusy(false); } });
    return () => { off = true; };
  }, [id]);

  const of = (s: string) => rows.filter((r) => r.status === s);
  const comp = base.comps.find((c: any) => c.id === id);
  const GROUPS: [string, string][] = [
    ['Competent', 'Can run it on their own'],
    ['Indirect', 'A Competent instructor nearby'],
    ['Direct', 'A Competent instructor beside them'],
    ['Not started', 'Nothing ticked yet'],
  ];

  return (
    <div className="mpanel" style={{ marginBottom: 14 }}>
      <h3 style={{ fontSize: 16, marginTop: 0 }}>Where everyone stands on one competency</h3>
      <Picker single options={base.comps.map((c: any) => ({ id: c.id, label: `${c.name} (L${c.level})` }))}
        value={pick} onChange={setPick} placeholder="Search for a competency…" />
      {!id ? <p className="muted" style={{ marginBottom: 0 }}>Pick a competency to see who is where on it.</p>
        : busy ? <p className="muted" style={{ marginBottom: 0 }}>Loading…</p>
        : <>
          <p className="muted" style={{ fontSize: 13 }}>
            {comp ? comp.name + ' (L' + comp.level + ')' : ''} · {rows.length} {rows.length === 1 ? 'instructor' : 'instructors'} ·
            {' '}{of('Competent').length} Competent, {of('Indirect').length} Indirect, {of('Direct').length} Direct
          </p>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(220px,1fr))', gap: 14 }}>
            {GROUPS.map(([s, why]) => (
              <div key={s} className="card" style={{ margin: 0 }}>
                <div className="rowflex" style={{ justifyContent: 'space-between', alignItems: 'baseline' }}>
                  <StatusPill status={s} /><b style={{ fontSize: 13 }}>{of(s).length}</b>
                </div>
                <small className="muted">{why}</small>
                {of(s).length === 0
                  ? <div className="muted" style={{ fontSize: 13, marginTop: 6 }}>Nobody.</div>
                  : of(s).map((r) => (
                    <div key={r.instructor_id} style={{ fontSize: 13.5, marginTop: 4 }}>
                      {r.instructor_name}
                      {s !== 'Competent' && s !== 'Not started' && <span className="muted"> · {r.done} of {r.total}</span>}
                    </div>
                  ))}
              </div>
            ))}
          </div>
        </>}
    </div>
  );
}

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
    <>
    <ByCompetency base={base} />
    <div className="mpanel">
      <h3 style={{ fontSize: 16, marginTop: 0 }}>Check a group of people against a list</h3>
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
    </>
  );
}

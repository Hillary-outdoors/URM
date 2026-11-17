'use client';
import { useEffect, useState } from 'react';
import { loadChecks, loadReady, loadRequirements, Checks } from '@/lib/util';
import { Picker, Matrix } from '@/components/ui';

/** Pick any instructors and any activities and see who can run what. */
export default function MatrixTab({ base }: any) {
  const [who, setWho] = useState<string[]>([]); const [acts, setActs] = useState<number[]>([]);
  const [checks, setChecks] = useState<Checks>({ comp: {}, amp: {} });
  const [reqs, setReqs] = useState<Record<number, any[]>>({});
  useEffect(() => {
    Promise.all([loadChecks(who, acts), loadReady(who, acts), loadRequirements(acts)])
      .then(([c, r, q]) => { setChecks({ ...c, ready: r }); setReqs(q); });
  }, [who, acts]);
  const people = base.instructors.filter((p: any) => p.account_type === 'instructor' && p.employment !== 'Past staff');
  return (
    <div className="mpanel">
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(280px,1fr))', gap: '0 20px' }}>
        <div><label className="f" style={{ marginTop: 0 }}>Instructors</label><Picker options={people.map((p: any) => ({ id: p.id, label: p.name }))} value={who} onChange={setWho} placeholder="Search for an instructor…" /></div>
        <div><label className="f" style={{ marginTop: 0 }}>Activities</label><Picker options={base.activities.filter((a: any) => a.active).map((a: any) => ({ id: a.id, label: a.name }))} value={acts} onChange={setActs} placeholder="Search for an activity…" /></div>
      </div>
      {acts.length > 0 && (
        <div className="hl" style={{ marginTop: 12 }}>
          {acts.map((id) => {
            const a = base.activities.find((x: any) => x.id === id); const r = reqs[id] || [];
            const comps = r.filter((x) => x.kind === 'Competency'), amps = r.filter((x) => x.kind === 'AMP');
            return (
              <div key={id} style={{ marginBottom: 6 }}>
                <b>{a?.name}</b> needs:{' '}
                {comps.length ? comps.map((x) => x.item_name + (x.everyone ? ' (everyone)' : '')).join(', ') : 'no competency listed yet'}
                {' · AMP: '}{amps.length ? amps.map((x) => x.item_name).join(', ') : 'none listed'}
              </div>
            );
          })}
        </div>
      )}
      <div style={{ marginTop: 14 }}>
        {who.length && acts.length
          ? <Matrix who={who.map((w) => ({ id: w, name: people.find((p: any) => p.id === w)?.name }))} acts={acts.map((a) => ({ id: a, name: base.activities.find((x: any) => x.id === a)?.name }))} checks={checks} />
          : <p className="muted">Add at least one instructor and one activity.</p>}
      </div>
      <p className="muted" style={{ fontSize: 13, margin: '10px 0 0', maxWidth: '75ch' }}>Each box shows whether that person meets everything the activity asks for. Hover a box to see what is missing. Covered means at least one of these instructors is Competent for that activity and all of them have signed the current AMP. The status shown is for the lowest-level competency linked to the activity.</p>
    </div>
  );
}

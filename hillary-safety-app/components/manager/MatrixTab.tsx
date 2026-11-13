'use client';
import { useEffect, useState } from 'react';
import { loadChecks, Checks } from '@/lib/util';
import { Picker, Matrix } from '@/components/ui';

/** Pick any instructors and any activities and see who can run what. */
export default function MatrixTab({ base }: any) {
  const [who, setWho] = useState<string[]>([]); const [acts, setActs] = useState<number[]>([]);
  const [checks, setChecks] = useState<Checks>({ comp: {}, amp: {} });
  useEffect(() => { loadChecks(who, acts).then(setChecks); }, [who, acts]);
  const people = base.instructors.filter((p: any) => p.account_type === 'instructor' && p.employment !== 'Past staff');
  return (
    <div className="mpanel">
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(280px,1fr))', gap: '0 20px' }}>
        <div><label className="f" style={{ marginTop: 0 }}>Instructors</label><Picker options={people.map((p: any) => ({ id: p.id, label: p.name }))} value={who} onChange={setWho} placeholder="Search for an instructor…" /></div>
        <div><label className="f" style={{ marginTop: 0 }}>Activities</label><Picker options={base.activities.filter((a: any) => a.active).map((a: any) => ({ id: a.id, label: a.name }))} value={acts} onChange={setActs} placeholder="Search for an activity…" /></div>
      </div>
      <div style={{ marginTop: 14 }}>
        {who.length && acts.length
          ? <Matrix who={who.map((w) => ({ id: w, name: people.find((p: any) => p.id === w)?.name }))} acts={acts.map((a) => ({ id: a, name: base.activities.find((x: any) => x.id === a)?.name }))} checks={checks} />
          : <p className="muted">Add at least one instructor and one activity.</p>}
      </div>
      <p className="muted" style={{ fontSize: 13, margin: '10px 0 0', maxWidth: '75ch' }}>Covered means at least one of these instructors is Competent for that activity and all of them have signed the current AMP. The status shown is for the lowest-level competency linked to the activity.</p>
    </div>
  );
}

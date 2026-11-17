'use client';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { loadReady, loadRequirements } from '@/lib/util';
import { Picker, StatusPill } from '@/components/ui';

type Mode = 'activity' | 'comp' | 'amp';
const MODES: [Mode, string, string][] = [
  ['activity', 'By activity', 'The usual way. Pick what the day is and the app works out the competencies and AMPs it needs.'],
  ['comp', 'By competency', 'For a one-off or an unusual trip. Pick the competencies you want people to hold.'],
  ['amp', 'By AMP', 'Pick the AMPs that must be signed, whatever else is going on.'],
];

/** Who can run what. Search by the activity, or straight by competency or AMP when the day is a one-off. */
export default function MatrixTab({ base }: any) {
  const [mode, setMode] = useState<Mode>('activity');
  const [who, setWho] = useState<string[]>([]);
  const [items, setItems] = useState<any[]>([]);
  const [ready, setReady] = useState<Record<string, { ready: boolean; missing: string }>>({});
  const [reqs, setReqs] = useState<Record<number, any[]>>({});
  const [comp, setComp] = useState<Record<string, string>>({});
  const [amp, setAmp] = useState<Record<string, boolean>>({});

  const people = base.instructors.filter((p: any) => p.account_type === 'instructor' && p.employment !== 'Past staff');
  const options = mode === 'activity'
    ? base.activities.filter((a: any) => a.active).map((a: any) => ({ id: a.id, label: a.name }))
    : mode === 'comp'
      ? base.comps.map((c: any) => ({ id: c.id, label: `${c.name} (L${c.level})` }))
      : base.amps.map((m: any) => ({ id: m.id, label: m.title }));
  const label = (id: any) => options.find((o: any) => o.id === id)?.label || '?';

  useEffect(() => { setItems([]); }, [mode]);
  useEffect(() => {
    if (!who.length || !items.length) { setReady({}); setReqs({}); setComp({}); setAmp({}); return; }
    (async () => {
      if (mode === 'activity') {
        const [r, q] = await Promise.all([loadReady(who, items), loadRequirements(items)]);
        setReady(r); setReqs(q);
      } else if (mode === 'comp') {
        const { data } = await supabase.from('v_competency_status').select('instructor_id,comp_id,status')
          .in('instructor_id', who).in('comp_id', items).limit(8000);
        const m: Record<string, string> = {};
        (data || []).forEach((x: any) => { m[x.instructor_id + '|' + x.comp_id] = x.status; });
        setComp(m);
      } else {
        const { data } = await supabase.from('v_amp_status').select('instructor_id,amp_id,up_to_date')
          .in('instructor_id', who).in('amp_id', items).limit(8000);
        const m: Record<string, boolean> = {};
        (data || []).forEach((x: any) => { m[x.instructor_id + '|' + x.amp_id] = x.up_to_date; });
        setAmp(m);
      }
    })();
  }, [who, items, mode]);

  function cell(wid: string, id: any) {
    if (mode === 'comp') { const s = comp[wid + '|' + id]; return <StatusPill status={s} />; }
    if (mode === 'amp') {
      const v = amp[wid + '|' + id];
      return <b className={v ? 'okc' : 'noc'}>{v === undefined ? 'No AMP yet' : v ? '✓ Signed' : '✗ Not signed'}</b>;
    }
    const r = ready[wid + '|' + id];
    if (!r) return <span className="muted">—</span>;
    return <span title={r.ready ? 'Has everything this activity asks for' : 'Still needs — ' + r.missing}>
      <b className={r.ready ? 'okc' : 'noc'}>{r.ready ? '✓ Ready' : '✗ Not ready'}</b>
      {!r.ready && <small className="noc">{(r.missing || '').split(' · ').length} missing</small>}
    </span>;
  }

  return (
    <div className="mpanel">
      <div className="rowflex" style={{ marginBottom: 10 }}>
        {MODES.map(([k, l, hint]) => (
          <button key={k} type="button" className={'btn small' + (mode === k ? ' primary' : '')} title={hint} onClick={() => setMode(k)}>{l}</button>
        ))}
      </div>
      <p className="muted" style={{ fontSize: 13, margin: '0 0 10px', maxWidth: '78ch' }}>{MODES.find((m) => m[0] === mode)![2]}</p>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(280px,1fr))', gap: '0 20px' }}>
        <div><label className="f" style={{ marginTop: 0 }}>Instructors</label>
          <Picker options={people.map((p: any) => ({ id: p.id, label: p.name }))} value={who} onChange={setWho} placeholder="Search instructors…" /></div>
        <div><label className="f" style={{ marginTop: 0 }}>{mode === 'activity' ? 'Activities' : mode === 'comp' ? 'Competencies' : 'AMPs'}</label>
          <Picker options={options} value={items} onChange={setItems} placeholder={'Search ' + (mode === 'activity' ? 'activities' : mode === 'comp' ? 'competencies' : 'AMPs') + '…'} /></div>
      </div>

      {mode === 'activity' && items.length > 0 && (
        <div className="hl" style={{ marginTop: 12 }}>
          {items.map((id) => {
            const r = reqs[id] || [];
            const cs = r.filter((x) => x.kind === 'Competency'), as = r.filter((x) => x.kind === 'AMP');
            return (
              <div key={id} style={{ marginBottom: 6 }}>
                <b>{label(id)}</b> needs:{' '}
                {cs.length ? cs.map((x) => x.item_name + (x.everyone ? ' (everyone)' : '')).join(', ') : <span className="noc">no competency linked yet</span>}
                {' · AMP: '}{as.length ? as.map((x) => x.item_name).join(', ') : 'none listed'}
              </div>
            );
          })}
        </div>
      )}

      <div style={{ marginTop: 14 }}>
        {who.length && items.length ? (
          <div className="scroll">
            <table className="mx">
              <thead><tr><th></th>{items.map((id) => <th key={id}>{label(id)}</th>)}</tr></thead>
              <tbody>
                {who.map((wid) => (
                  <tr key={wid}><th>{people.find((p: any) => p.id === wid)?.name}</th>
                    {items.map((id) => <td key={id}>{cell(wid, id)}</td>)}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : <p className="muted">Add at least one instructor and one {mode === 'activity' ? 'activity' : mode === 'comp' ? 'competency' : 'AMP'}.</p>}
      </div>
      <p className="muted" style={{ fontSize: 13, margin: '10px 0 0', maxWidth: '78ch' }}>
        Ready means that person holds every competency and has signed every AMP the activity asks for, including the ones everyone needs.
        Hover a box to see what is missing. For a day that does not fit any of the presets, use “By competency” or “By AMP”, or pin the
        exact requirements onto that intention from the day sheet.
      </p>
    </div>
  );
}

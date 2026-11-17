'use client';
import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { Picker, Pill } from '@/components/ui';

const dmName = () => { try { return localStorage.getItem('dmName') || ''; } catch (e) { return ''; } };

/**
 * For a day that does not fit any of the preset activities: the DM pins the exact competencies
 * and AMPs this intention needs, and the app checks the people on it against those as well.
 */
export default function ExtraReqs({ base, intentionId, who }: any) {
  const [open, setOpen] = useState(false);
  const [comps, setComps] = useState<number[]>([]);
  const [amps, setAmps] = useState<number[]>([]);
  const [ready, setReady] = useState<any[]>([]);
  const [busy, setBusy] = useState(false);

  const load = useCallback(async () => {
    const [c, a, r] = await Promise.all([
      supabase.from('intention_comps').select('comp_id').eq('intention_id', intentionId),
      supabase.from('intention_amps').select('amp_id').eq('intention_id', intentionId),
      supabase.from('v_intention_ready').select('instructor_id,ready,missing').eq('intention_id', intentionId),
    ]);
    setComps((c.data || []).map((x: any) => x.comp_id));
    setAmps((a.data || []).map((x: any) => x.amp_id));
    setReady(r.data || []);
    if ((c.data || []).length || (a.data || []).length) setOpen(true);
  }, [intentionId]);
  useEffect(() => { load(); }, [load, who.join(',')]);

  async function save(nextC: number[], nextA: number[]) {
    setBusy(true);
    await supabase.from('intention_comps').delete().eq('intention_id', intentionId);
    await supabase.from('intention_amps').delete().eq('intention_id', intentionId);
    if (nextC.length) await supabase.from('intention_comps').insert(nextC.map((id) => ({ intention_id: intentionId, comp_id: id, added_by: dmName() || null })));
    if (nextA.length) await supabase.from('intention_amps').insert(nextA.map((id) => ({ intention_id: intentionId, amp_id: id, added_by: dmName() || null })));
    setBusy(false); load();
  }
  const nm = (id: string) => base.instructors.find((x: any) => x.id === id)?.name || '?';
  const short = ready.filter((r) => who.includes(r.instructor_id) && !r.ready);

  if (!open) return (
    <button type="button" className="btn small" style={{ marginTop: 8 }} onClick={() => setOpen(true)}>
      This day is a one-off — set its own competencies and AMPs
    </button>
  );
  return (
    <div className="hl" style={{ marginTop: 10 }}>
      <b>What this particular day needs</b>
      <p className="muted" style={{ fontSize: 13, margin: '4px 0 8px', maxWidth: '72ch' }}>
        Only for a day the preset activities do not describe. Anything added here is checked on top of
        whatever the activities already ask for.
      </p>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(260px,1fr))', gap: '0 16px' }}>
        <div><label className="f" style={{ marginTop: 0 }}>Competencies they must hold</label>
          <Picker options={base.comps.map((c: any) => ({ id: c.id, label: `${c.name} (L${c.level})` }))}
            value={comps} onChange={(v) => { setComps(v as number[]); save(v as number[], amps); }} placeholder="Search competencies…" /></div>
        <div><label className="f" style={{ marginTop: 0 }}>AMPs they must have signed</label>
          <Picker options={base.amps.map((m: any) => ({ id: m.id, label: m.title }))}
            value={amps} onChange={(v) => { setAmps(v as number[]); save(comps, v as number[]); }} placeholder="Search AMPs…" /></div>
      </div>
      <div style={{ marginTop: 8 }}>
        {busy ? <span className="muted">Saving…</span>
          : short.length
            ? short.map((r) => <div key={r.instructor_id} className="noc"><b>{nm(r.instructor_id)}</b> still needs — {r.missing}</div>)
            : <span className="okc">{who.length ? 'Everyone on this intention has what it asks for.' : 'Add the instructors to see the check.'}</span>}
      </div>
    </div>
  );
}

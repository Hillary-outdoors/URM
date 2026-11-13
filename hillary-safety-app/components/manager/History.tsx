'use client';
import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { INT_SELECT, shapeInt, loadChecks, nzToday, daysAgo, downloadCsv, intentionRows, Checks } from '@/lib/util';
import { Sheet } from '@/components/ui';
import IntentionTable from './IntentionTable';
import { IntentionSheet } from './IntentionSheet';

/** Look back at any intention. Filter by date, person, activity, centre or status. */
export default function History({ base }: any) {
  const [f, setF] = useState({ from: daysAgo(14), to: nzToday(), who: '', act: '', centre: '', status: '' });
  const [rows, setRows] = useState<any[]>([]); const [checks, setChecks] = useState<Checks>({ comp: {}, amp: {} }); const [sel, setSel] = useState<any>(null);
  const load = useCallback(async () => {
    let q = supabase.from('intentions').select(INT_SELECT).gte('date', f.from).lte('date', f.to).order('date', { ascending: false }).order('id', { ascending: false }).limit(1000);
    if (f.centre) q = q.eq('centre_id', +f.centre);
    if (f.status) q = q.eq('status', f.status);
    const { data } = await q;
    const list = (data || []).map(shapeInt); setRows(list);
    setChecks(await loadChecks([...new Set(list.flatMap((x: any) => x.who))] as string[], [...new Set(list.flatMap((x: any) => x.acts))] as number[]));
  }, [f.from, f.to, f.centre, f.status]);
  useEffect(() => { load(); }, [load]);

  const q = f.who.trim().toLowerCase();
  const shown = rows.filter((i) => (!f.act || i.acts.includes(+f.act)) && (!q || i.who.some((w: string) => (base.instructors.find((x: any) => x.id === w)?.name || '').toLowerCase().includes(q))));
  const set = (k: string) => (e: any) => setF({ ...f, [k]: e.target.value });
  return (
    <div className="mpanel">
      <div className="filters">
        <div style={{ minWidth: 140 }}><label className="f" style={{ marginTop: 0 }} htmlFor="hf">From</label><input id="hf" type="date" value={f.from} onChange={set('from')} /></div>
        <div style={{ minWidth: 140 }}><label className="f" style={{ marginTop: 0 }} htmlFor="ht">To</label><input id="ht" type="date" value={f.to} onChange={set('to')} /></div>
        <div><label className="f" style={{ marginTop: 0 }} htmlFor="hw">Instructor</label><input id="hw" type="text" value={f.who} onChange={set('who')} placeholder="Type a name" /></div>
        <div><label className="f" style={{ marginTop: 0 }} htmlFor="ha">Activity</label><select id="ha" value={f.act} onChange={set('act')}><option value="">All</option>{base.activities.map((a: any) => <option key={a.id} value={a.id}>{a.name}</option>)}</select></div>
        <div style={{ minWidth: 130 }}><label className="f" style={{ marginTop: 0 }} htmlFor="hc">Centre</label><select id="hc" value={f.centre} onChange={set('centre')}><option value="">All</option>{base.centres.map((c: any) => <option key={c.id} value={c.id}>{c.name}</option>)}</select></div>
        <div style={{ minWidth: 120 }}><label className="f" style={{ marginTop: 0 }} htmlFor="hs">Status</label><select id="hs" value={f.status} onChange={set('status')}><option value="">All</option><option>Waiting</option><option>Approved</option><option>Closed</option></select></div>
        <button className="btn" onClick={() => downloadCsv('intentions.csv', intentionRows(shown, base.instructors, base.activities))}>Export these {shown.length}</button>
      </div>
      <IntentionTable rows={shown} base={base} checks={checks} showDate onOpen={setSel} />
      {rows.length === 1000 && <p className="muted">Showing the newest 1,000. Narrow the dates to see older ones.</p>}
      <Sheet open={!!sel} onClose={() => setSel(null)}>{sel && <IntentionSheet intention={sel} base={base} onDone={() => { setSel(null); load(); }} />}</Sheet>
    </div>
  );
}

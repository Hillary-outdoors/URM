'use client';
import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { nzToday, fd, hm } from '@/lib/util';
import { Pill } from '@/components/ui';

/**
 * Who else is out today. Instructors see the whole day for their centre so
 * they can work out how it fits together: who is where, doing what, and when
 * they are due back. The DM's private notes are not in this view.
 */
export default function DayBoard({ me, centres }: { me: any; centres: any[] }) {
  const [date, setDate] = useState(nzToday());
  const [centre, setCentre] = useState<number>(me.centre_id || centres[0]?.id || 0);
  const [rows, setRows] = useState<any[]>([]); const [loading, setLoading] = useState(true); const [err, setErr] = useState('');

  const load = useCallback(async () => {
    if (!centre) { setLoading(false); return; }
    setLoading(true);
    const { data, error } = await supabase.from('v_day_board').select('*').eq('date', date).eq('centre_id', centre).limit(200);
    if (error) setErr(error.message); else setErr('');
    const order = (r: any) => (r.started_at || r.due_by || '99:99');
    setRows((data || []).sort((a: any, b: any) => order(a).localeCompare(order(b))));
    setLoading(false);
  }, [date, centre]);
  useEffect(() => { load(); }, [load]);

  const shift = (n: number) => {
    const d = new Date(date + 'T12:00:00Z'); d.setUTCDate(d.getUTCDate() + n); setDate(d.toISOString().slice(0, 10));
  };
  const out = rows.filter((r) => r.status !== 'Closed');
  const back = rows.filter((r) => r.status === 'Closed');

  return (
    <>
      <div className="card">
        <h3>Who is out</h3>
        <div className="rowflex" style={{ marginTop: 6 }}>
          <button className="btn small" onClick={() => shift(-1)} aria-label="Previous day">‹</button>
          <input type="date" style={{ flex: 1, minWidth: 150 }} value={date} onChange={(e) => setDate(e.target.value || nzToday())} aria-label="Day to show" />
          <button className="btn small" onClick={() => shift(1)} aria-label="Next day">›</button>
        </div>
        {date !== nzToday() && <button className="btn small" style={{ marginTop: 6 }} onClick={() => setDate(nzToday())}>Back to today</button>}
        {centres.length > 1 && (
          <div className="seg" style={{ marginTop: 8 }}>
            {centres.map((c) => <button key={c.id} className={centre === c.id ? 'on' : ''} onClick={() => setCentre(c.id)}>{c.name}</button>)}
          </div>
        )}
        <p className="muted" style={{ fontSize: 12.5, margin: '8px 0 0' }}>
          Everyone on the board for {fd(date)}. Useful for sorting out vehicles, gear and who is where. The DM's own notes are not shown here.
        </p>
      </div>

      {err && <div className="inc">{err}</div>}
      {loading && <div className="card muted">Loading…</div>}

      {!loading && !rows.length && <div className="card muted">Nothing on the board for this day yet.</div>}

      {!!out.length && <div className="sec">Still out ({out.length})</div>}
      {out.map((r) => <Trip key={r.intention_id} r={r} me={me} />)}
      {!!back.length && <div className="sec">Finished ({back.length})</div>}
      {back.map((r) => <Trip key={r.intention_id} r={r} me={me} />)}
    </>
  );
}

function Trip({ r, me }: { r: any; me: any }) {
  const mine = (r.instructor_ids || []).includes(me.id);
  return (
    <div className="card" style={mine ? { borderLeft: '5px solid var(--accent)' } : undefined}>
      <div className="rowflex" style={{ justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <h3 style={{ marginBottom: 2 }}>{r.activity_names || 'No activity'}</h3>
        <Pill kind={r.status === 'Waiting' ? 'warn' : r.status === 'Approved' ? 'good' : 'mute'}>{r.status}</Pill>
      </div>
      <div>{r.instructor_names || 'Nobody'}{mine && <> <Pill kind="info">You</Pill></>}</div>
      <small className="muted">
        {r.needs_call_in
          ? <>{r.started_at ? 'Started ' + hm(r.started_at) : 'Not started yet'}{r.due_by ? ' · due ' + hm(r.due_by) : ''}{r.called_in_at ? ` · ${r.called_in_as} ${hm(r.called_in_at)}` : ''}</>
          : <>No call-in needed{r.called_in_at ? ` · finished ${hm(r.called_in_at)}` : ''}</>}
        {r.overnight ? ' · overnight' : ''}
      </small>
      {(r.group_name || r.pax) && <div style={{ fontSize: 13.5 }}>{[r.group_name, r.pax && r.pax + ' pax'].filter(Boolean).join(' · ')}</div>}
      {r.outcome_of_day && <div style={{ fontSize: 13.5 }}>Outcome of the day: {r.outcome_of_day}</div>}
      {r.plan && <div><small>Plan: {r.plan}</small></div>}
    </div>
  );
}

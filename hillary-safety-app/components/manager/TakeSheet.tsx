'use client';
import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { fd, hm, downloadCsv } from '@/lib/util';

/**
 * The take sheet: one page per day listing every trip, who is on it, what they take, what calls
 * they owe and what is different about today — conditions, closures, tides. Printed and pinned up,
 * or downloaded as a spreadsheet.
 */
export default function TakeSheet({ date, centre, centreName, onClose }: any) {
  const [rows, setRows] = useState<any[]>([]);
  const [day, setDay] = useState<any>(null);
  const [err, setErr] = useState('');

  const load = useCallback(async () => {
    const [t, d] = await Promise.all([
      supabase.from('v_take_sheet').select('*').eq('date', date).eq('centre_id', centre).order('intention_id'),
      supabase.from('v_day_sheet').select('*').eq('date', date).eq('centre_id', centre).maybeSingle(),
    ]);
    if (t.error) setErr(t.error.message);
    setRows(t.data || []); setDay(d.data || null);
  }, [date, centre]);
  useEffect(() => { load(); }, [load]);

  function csv() {
    const cols = ['group_name', 'pax', 'instructors', 'activities', 'plan', 'outcome_of_day',
      'started_at', 'due_by', 'calls_required', 'calls_always', 'calls_made',
      'take_with_you', 'other_resources', 'emergency_response'];
    const head = ['Group', 'Pax', 'Instructors', 'Activities', 'Plan', 'Aim of the day',
      'Out', 'Due back', 'Calls for this trip', 'Always', 'Calls made',
      'Take with you', 'Other resources', 'Emergency response'];
    downloadCsv(`URMA-take-sheet-${date}.csv`, [
      ['Day sheet', centreName, fd(date)],
      ['DM', day?.dm_name || '', 'Weather', day?.wx_state || '', day?.forecast || ''],
      ['Weather events', day?.weather_events || 'None'],
      ['Avalanche', day?.avalanche || 'Nil'],
      ['River levels', day?.river_levels || ''],
      ['Closures', day?.closures || 'None'],
      ['Tides', day?.tide_notes || '', 'Sunset', day?.sunset ? hm(day.sunset) : ''],
      [], head, ...rows.map((r) => cols.map((c) => (c === 'started_at' || c === 'due_by' ? (r[c] ? hm(r[c]) : '') : r[c] ?? ''))),
    ]);
  }

  const bit = (label: string, value: any) => value
    ? <div style={{ marginBottom: 2 }}><b style={{ fontSize: 12.5 }}>{label}:</b> <span style={{ fontSize: 12.5 }}>{value}</span></div>
    : null;

  return (
    <div className="takesheet">
      <div className="noprint rowflex" style={{ marginBottom: 10 }}>
        <button className="btn primary" onClick={() => window.print()}>Print</button>
        <button className="btn" onClick={csv}>Download as a spreadsheet</button>
        {onClose && <button className="btn" onClick={onClose}>Close</button>}
        <span className="muted" style={{ alignSelf: 'center', fontSize: 13 }}>{rows.length} trip{rows.length === 1 ? '' : 's'}</span>
      </div>
      {err && <div className="msg bad">{err}</div>}

      <h2 style={{ marginBottom: 2 }}>{centreName} · {fd(date)}</h2>
      <div className="muted" style={{ fontSize: 13, marginBottom: 10 }}>Duty manager: {day?.dm_name || '—'}</div>

      <div className="card" style={{ marginBottom: 12 }}>
        <b style={{ fontSize: 14 }}>Today</b>
        <div style={{ marginTop: 6 }}>
          {bit('Weather', [day?.wx_state, day?.forecast].filter(Boolean).join(' · '))}
          {bit('Watches and warnings', day?.weather_events)}
          {bit('Avalanche', day?.avalanche)}
          {bit('River levels', day?.river_levels)}
          {bit('Closures', day?.closures)}
          {bit('Tides', day?.tide_notes)}
          {bit('Sunset', day?.sunset ? hm(day.sunset) : null)}
          {bit('Weather notes', day?.wx_notes)}
          {bit('DM judgements', day?.dm_judgements)}
          {!day && <span className="muted" style={{ fontSize: 13 }}>No day sheet filled in yet.</span>}
        </div>
      </div>

      {rows.length === 0 ? <p className="muted">No trips on this day.</p> : rows.map((r) => (
        <div className="card" key={r.intention_id} style={{ marginBottom: 10, breakInside: 'avoid' }}>
          <div className="rowflex" style={{ justifyContent: 'space-between', alignItems: 'baseline' }}>
            <b>{r.group_name || 'Trip'}{r.pax ? ' · ' + r.pax + ' pax' : ''}{r.overnight ? ' · overnight' : ''}</b>
            <span style={{ fontSize: 12.5 }}>
              {r.started_at ? 'out ' + hm(r.started_at) : 'not away yet'}{r.due_by ? ' · due ' + hm(r.due_by) : ''}
            </span>
          </div>
          <div style={{ marginTop: 4 }}>
            {bit('Instructors', r.instructors)}
            {bit('Activities', r.activities)}
            {bit('Plan', r.plan)}
            {bit('Aim of the day', r.outcome_of_day)}
            {bit('Calls', [r.calls_required, r.calls_always].filter(Boolean).join(' · '))}
            {bit('Calls made', r.calls_made)}
            {bit('Take with you', r.take_with_you)}
            {bit('Other resources', r.other_resources)}
            {bit('Emergency response', r.emergency_response)}
          </div>
        </div>
      ))}
    </div>
  );
}

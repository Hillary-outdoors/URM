'use client';
import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { fd, hm, downloadCsv } from '@/lib/util';

/**
 * Every day sheet the DM has filled in, newest first, to look back at. The day sheet view already
 * gathers the weather, thunderstorms, avalanche, rivers and closures into one row per day, so this
 * is a straight read of it — nothing here can change anything.
 */

const FIELDS: [string, string][] = [
  ['wx_state', 'Weather state'],
  ['forecast', 'Forecast'],
  ['weather_events', 'Watches and warnings'],
  ['thunderstorm', 'Thunderstorms'],
  ['avalanche', 'Avalanche'],
  ['river_levels', 'River levels'],
  ['closures', 'Closures'],
  ['tide_notes', 'Tides'],
  ['sunset', 'Sunset'],
  ['wx_notes', 'Weather notes and other'],
  ['dm_judgements', 'DM judgements and discussions'],
];

export default function DayHistory({ centre, centreName, onClose }: any) {
  const [rows, setRows] = useState<any[]>([]);
  const [open, setOpen] = useState<string>('');
  const [busy, setBusy] = useState(true);
  const [err, setErr] = useState('');

  const load = useCallback(async () => {
    if (!centre) return;
    setBusy(true);
    const { data, error } = await supabase.from('v_day_sheet').select('*')
      .eq('centre_id', centre).order('date', { ascending: false }).limit(400);
    if (error) setErr(error.message);
    setRows(data || []); setBusy(false);
  }, [centre]);
  useEffect(() => { load(); }, [load]);

  const val = (r: any, k: string) => (k === 'sunset' ? (r.sunset ? hm(r.sunset) : '') : r[k]);
  const filled = (r: any) => FIELDS.filter(([k]) => val(r, k)).length;

  return (
    <>
      <div className="filters" style={{ marginBottom: 10 }}>
        <h3 style={{ fontSize: 16, alignSelf: 'center', margin: 0 }}>Past days · {centreName}</h3>
        <button className="btn" onClick={onClose}>Back to today</button>
        {rows.length > 0 && <button className="btn" style={{ marginLeft: 'auto' }} onClick={() => downloadCsv(
          'day-sheets-' + centreName.toLowerCase().replace(/\s+/g, '-') + '.csv',
          [['Date', 'DM', ...FIELDS.map(([, l]) => l)],
            ...rows.map((r) => [r.date, r.dm_name || '', ...FIELDS.map(([k]) => val(r, k) || '')])])}>Export</button>}
      </div>

      {err && <div className="msg bad">{err}</div>}
      {busy ? <p className="muted">Loading…</p>
        : rows.length === 0 ? <p className="muted">No day sheets recorded for this centre yet.</p>
        : rows.map((r) => (
          <div key={r.date} className="card" style={{ margin: '0 0 8px' }}>
            <button className="rowbtn" style={{ border: 0, padding: 0, width: '100%' }}
              onClick={() => setOpen(open === r.date ? '' : r.date)}>
              <span style={{ flex: 1 }}>
                <span className="t">{fd(r.date)}</span>
                <small>{[r.dm_name && 'DM ' + r.dm_name, r.wx_state, r.closures && 'closures',
                          r.thunderstorm && 'thunderstorms'].filter(Boolean).join(' · ') || 'Nothing recorded'}</small>
              </span>
              <span className="muted" style={{ fontSize: 12.5 }}>{filled(r)} filled {open === r.date ? '▾' : '▸'}</span>
            </button>
            {open === r.date && (
              <dl style={{ marginTop: 8 }}>
                {FIELDS.filter(([k]) => val(r, k)).map(([k, l]) => (
                  <span key={k} style={{ display: 'contents' }}><dt>{l}</dt><dd>{val(r, k)}</dd></span>
                ))}
                {filled(r) === 0 && <span style={{ display: 'contents' }}><dt>—</dt><dd className="muted">Only the DM name was filled in.</dd></span>}
              </dl>
            )}
          </div>
        ))}
    </>
  );
}

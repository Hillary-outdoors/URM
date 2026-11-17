'use client';
import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

/**
 * Weather events, avalanche, river levels and closures — each as a list, because a real day has
 * two warnings at once, a different avalanche rating at every elevation band, four rivers reading
 * differently and three separate closures.
 *
 * The avalanche rows come pre-made from the elevation bands for the centre, so the DM only has to
 * pick a rating against each one.
 */

const KINDS: { kind: string; title: string; placeLabel: string; placeHint: string; readings?: string[]; readingHint?: string }[] = [
  { kind: 'Weather', title: 'Weather watches and warnings', placeLabel: 'Where', placeHint: 'Central North Island',
    readings: ['Heavy rain warning', 'Heavy rain watch', 'Strong wind warning', 'Strong wind watch',
               'Thunderstorm watch', 'Snow warning', 'Snow watch', 'Road snowfall warning'] },
  { kind: 'Avalanche', title: 'Avalanche', placeLabel: 'Band', placeHint: 'Alpine',
    readings: ['Nil', 'Green', 'Yellow', 'Orange', 'Red', 'Black'] },
  { kind: 'River', title: 'River levels', placeLabel: 'River and gauge', placeHint: 'Whanganui at Cherry Grove',
    readingHint: '1.4m and rising' },
  { kind: 'Closure', title: 'Closures', placeLabel: 'What is closed', placeHint: 'Upper Mangatepopo',
    readings: ['Closed', 'Closed — slip', 'Closed — flooding', 'Closed — fire risk', 'Open with care'] },
];

export default function DayConditions({ date, centre, dmName, alpine, onChange }: any) {
  const [rows, setRows] = useState<any[]>([]);
  const [bands, setBands] = useState<any[]>([]);
  const [err, setErr] = useState('');

  const load = useCallback(async () => {
    if (!centre) return;
    const [r, b] = await Promise.all([
      supabase.from('dm_day_conditions').select('*').eq('date', date).eq('centre_id', centre).order('kind').order('sort_order').order('id'),
      supabase.from('avalanche_bands').select('*').eq('centre_id', centre).order('sort_order'),
    ]);
    setRows(r.data || []); setBands(b.data || []);
  }, [date, centre]);
  useEffect(() => { load(); }, [load]);

  async function add(kind: string, place = '', reading = '') {
    const sort = rows.filter((x) => x.kind === kind).length + 1;
    const { error } = await supabase.from('dm_day_conditions')
      .insert({ date, centre_id: centre, kind, place: place || null, reading: reading || '', sort_order: sort, added_by: dmName || null });
    if (error) return setErr(error.message);
    load(); onChange?.();
  }
  async function patch(id: number, field: string, value: string) {
    setRows((p) => p.map((x) => (x.id === id ? { ...x, [field]: value } : x)));
    const { error } = await supabase.from('dm_day_conditions').update({ [field]: value || null }).eq('id', id);
    if (error) setErr(error.message); else onChange?.();
  }
  async function remove(id: number) {
    const { error } = await supabase.from('dm_day_conditions').delete().eq('id', id);
    if (error) return setErr(error.message);
    load(); onChange?.();
  }
  /** Puts one row up for each elevation band, so all three get a rating. */
  async function fillBands() {
    const have = rows.filter((x) => x.kind === 'Avalanche').map((x) => (x.place || '').toLowerCase());
    const missing = bands.filter((b) => !have.includes(b.band.toLowerCase()));
    if (!missing.length) return;
    const { error } = await supabase.from('dm_day_conditions').insert(missing.map((b) => ({
      date, centre_id: centre, kind: 'Avalanche', place: b.band, reading: 'Nil',
      sort_order: b.sort_order, added_by: dmName || null,
    })));
    if (error) return setErr(error.message);
    load(); onChange?.();
  }

  return (
    <div style={{ marginTop: 10 }}>
      {err && <div className="msg bad">{err}</div>}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(290px,1fr))', gap: 14 }}>
        {KINDS.filter((k) => k.kind !== 'Avalanche' || alpine).map((k) => {
          const mine = rows.filter((x) => x.kind === k.kind);
          return (
            <div key={k.kind} className="card" style={{ margin: 0 }}>
              <div className="rowflex" style={{ justifyContent: 'space-between', alignItems: 'baseline' }}>
                <b style={{ fontSize: 14 }}>{k.title}</b>
                <div className="rowflex" style={{ gap: 6 }}>
                  {k.kind === 'Avalanche' && bands.length > 0 && mine.length < bands.length &&
                    <button className="btn small" onClick={fillBands}>Add all {bands.length} bands</button>}
                  <button className="btn small" onClick={() => add(k.kind)}>+ Add</button>
                </div>
              </div>
              {mine.length === 0 && <div className="muted" style={{ fontSize: 13, marginTop: 6 }}>
                {k.kind === 'Weather' ? 'Nothing in force.' : k.kind === 'Avalanche' ? 'No rating set.'
                  : k.kind === 'River' ? 'No levels noted.' : 'Nothing closed.'}
              </div>}
              {mine.map((x) => (
                <div key={x.id} className="rowflex" style={{ gap: 6, marginTop: 6, alignItems: 'center' }}>
                  <input type="text" aria-label={k.placeLabel} placeholder={k.placeHint} style={{ flex: 1, minWidth: 90 }}
                    value={x.place || ''} onChange={(e) => patch(x.id, 'place', e.target.value)} />
                  {k.readings
                    ? <select aria-label="Reading" style={{ flex: 1, minWidth: 110 }} value={x.reading || ''}
                        onChange={(e) => patch(x.id, 'reading', e.target.value)}>
                        <option value="">—</option>
                        {k.readings.map((o) => <option key={o} value={o}>{o}</option>)}
                      </select>
                    : <input type="text" aria-label="Reading" placeholder={k.readingHint} style={{ flex: 1, minWidth: 90 }}
                        value={x.reading || ''} onChange={(e) => patch(x.id, 'reading', e.target.value)} />}
                  <button className="btn small" aria-label="Remove" onClick={() => remove(x.id)}>×</button>
                </div>
              ))}
            </div>
          );
        })}
      </div>
    </div>
  );
}

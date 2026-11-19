'use client';
import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

/**
 * Weather events, thunderstorms, avalanche, river levels and closures — each as a list, because a
 * real day has two warnings at once, a different avalanche rating at every elevation band, four
 * rivers reading differently and three separate closures.
 *
 * The avalanche rows come pre-made from the elevation bands for the centre, and thunderstorms come
 * pre-made as AM and PM, so the DM only has to pick a rating against each one. River names are
 * remembered from every day before, so the same gauge is one tap the second time.
 */

type Kind = {
  kind: string; title: string; placeLabel: string; placeHint: string;
  placeOptions?: string[];       // a dropdown for the left-hand box
  remembers?: boolean;           // offer whatever has been typed here before
  readings?: string[]; readingHint?: string;
  empty: string;
};

const KINDS: Kind[] = [
  { kind: 'Weather', title: 'Weather watches and warnings', placeLabel: 'Where', placeHint: 'Central North Island',
    readings: ['Heavy rain warning', 'Heavy rain watch', 'Strong wind warning', 'Strong wind watch',
               'Snow warning', 'Snow watch', 'Road snowfall warning'],
    empty: 'Nothing in force.' },
  { kind: 'Thunderstorm', title: 'Thunderstorm watches', placeLabel: 'When', placeHint: 'AM',
    placeOptions: ['AM', 'PM', 'All day'],
    readings: ['Low risk', 'Moderate risk', 'Severe risk'],
    empty: 'None forecast.' },
  { kind: 'Avalanche', title: 'Avalanche', placeLabel: 'Band', placeHint: 'Alpine',
    readings: ['Nil', 'Green', 'Yellow', 'Orange', 'Red', 'Black'],
    empty: 'No rating set.' },
  { kind: 'River', title: 'River levels', placeLabel: 'River and gauge', placeHint: 'Whanganui at Cherry Grove',
    remembers: true, readingHint: '1.4m and rising',
    empty: 'No levels noted.' },
  { kind: 'Closure', title: 'Closures', placeLabel: 'What is closed', placeHint: 'Upper Mangatepopo',
    readings: ['Closed', 'Closed — slip', 'Closed — flooding', 'Closed — fire risk', 'Open with care'],
    empty: 'Nothing closed.' },
];

const TIMES = ['AM', 'PM'];

export default function DayConditions({ date, centre, dmName, alpine, onChange }: any) {
  const [rows, setRows] = useState<any[]>([]);
  const [bands, setBands] = useState<any[]>([]);
  const [seen, setSeen] = useState<string[]>([]);   // river names used on any day before
  const [err, setErr] = useState('');

  const load = useCallback(async () => {
    if (!centre) return;
    const [r, b, p] = await Promise.all([
      supabase.from('dm_day_conditions').select('*').eq('date', date).eq('centre_id', centre).order('kind').order('sort_order').order('id'),
      supabase.from('avalanche_bands').select('*').eq('centre_id', centre).order('sort_order'),
      // Every river name this centre has ever put in, so it can be picked instead of retyped.
      supabase.from('dm_day_conditions').select('place').eq('centre_id', centre).eq('kind', 'River')
        .not('place', 'is', null).limit(2000),
    ]);
    setRows(r.data || []); setBands(b.data || []);
    setSeen([...new Set((p.data || []).map((x: any) => (x.place || '').trim()).filter(Boolean))].sort());
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
  /** Thunderstorms come in halves of the day, so put both up at once. */
  async function fillTimes() {
    const have = rows.filter((x) => x.kind === 'Thunderstorm').map((x) => (x.place || '').toUpperCase());
    const missing = TIMES.filter((t) => !have.includes(t));
    if (!missing.length) return;
    const { error } = await supabase.from('dm_day_conditions').insert(missing.map((t, n) => ({
      date, centre_id: centre, kind: 'Thunderstorm', place: t, reading: 'Low risk',
      sort_order: n + 1, added_by: dmName || null,
    })));
    if (error) return setErr(error.message);
    load(); onChange?.();
  }

  return (
    <div style={{ marginTop: 10 }}>
      {err && <div className="msg bad">{err}</div>}
      {/* One shared list of river names, offered to every river box on the page. */}
      <datalist id="dc-rivers">{seen.map((s) => <option key={s} value={s} />)}</datalist>
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
                  {k.kind === 'Thunderstorm' && mine.length < TIMES.length &&
                    <button className="btn small" onClick={fillTimes}>Add AM and PM</button>}
                  <button className="btn small" onClick={() => add(k.kind)}>+ Add</button>
                </div>
              </div>
              {mine.length === 0 && <div className="muted" style={{ fontSize: 13, marginTop: 6 }}>{k.empty}</div>}
              {mine.map((x) => (
                <div key={x.id} className="rowflex" style={{ gap: 6, marginTop: 6, alignItems: 'center' }}>
                  {k.placeOptions
                    ? <select aria-label={k.placeLabel} style={{ flex: 1, minWidth: 90 }} value={x.place || ''}
                        onChange={(e) => patch(x.id, 'place', e.target.value)}>
                        <option value="">—</option>
                        {k.placeOptions.map((o) => <option key={o} value={o}>{o}</option>)}
                      </select>
                    : <input type="text" aria-label={k.placeLabel} placeholder={k.placeHint}
                        list={k.remembers ? 'dc-rivers' : undefined}
                        style={{ flex: 1, minWidth: 90 }}
                        value={x.place || ''} onChange={(e) => patch(x.id, 'place', e.target.value)} />}
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
              {k.remembers && seen.length > 0 && mine.length > 0 &&
                <small className="muted">Start typing to pick from the {seen.length} {seen.length === 1 ? 'river' : 'rivers'} used before.</small>}
            </div>
          );
        })}
      </div>
    </div>
  );
}

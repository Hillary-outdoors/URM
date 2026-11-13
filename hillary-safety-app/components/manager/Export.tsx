'use client';
import { useState } from 'react';
import { supabase } from '@/lib/supabase';
import { INT_SELECT, shapeInt, nzToday, daysAgo, fd, hm, downloadCsv, intentionRows, fetchAll } from '@/lib/util';

const SETS: [string, string, string][] = [
  ['doc', 'DOC activity report', 'Groups and participants per activity inside the national park, for the dates chosen'],
  ['int', 'Intentions', 'Every intention in the dates chosen, with plan, call-in times, DM notes and outcome of the day'],
  ['days', 'DM day sheets', 'Weather, river levels, closures and DM judgements for the dates chosen'],
  ['comms', 'DM comms log', 'Every timed entry in the dates chosen'],
  ['ticks', 'Competency sign-offs', 'One row per tick: who, which line, who signed it, when and why'],
  ['status', 'Competency status summary', 'Every current instructor against every competency'],
  ['acks', 'AMP acknowledgements', 'Who has signed the current version of each AMP'],
  ['log', 'Change log', 'Sign-offs, removed ticks, AMP versions and login changes'],
  ['people', 'Instructors', 'Details and qualifications held'],
];

/** Download any record set as a spreadsheet, for audits and DOC returns. */
export default function Export({ base }: any) {
  const [from, setFrom] = useState(daysAgo(30)); const [to, setTo] = useState(nzToday()); const [msg, setMsg] = useState<[string, string]>(['', '']); const [busy, setBusy] = useState('');
  const nm = (id: string) => base.instructors.find((x: any) => x.id === id)?.name || '';
  const an = (id: number) => base.activities.find((x: any) => x.id === id)?.name || '';
  const cn = (id: number) => base.centres.find((x: any) => x.id === id)?.name || '';

  async function build(k: string): Promise<any[][]> {
    if (k === 'int' || k === 'doc') {
      const list = (await fetchAll(() => supabase.from('intentions').select(INT_SELECT).gte('date', from).lte('date', to).order('date').order('id'))).map(shapeInt);
      if (k === 'int') return intentionRows(list, base.instructors, base.activities);
      const m: Record<number, { g: number; p: number; d: Set<string> }> = {};
      list.forEach((i: any) => i.acts.filter((a: number) => base.activities.find((x: any) => x.id === a)?.in_national_park).forEach((a: number) => {
        const o = (m[a] = m[a] || { g: 0, p: 0, d: new Set() }); o.g++; o.p += +i.pax || 0; o.d.add(i.date);
      }));
      return [['Activity', 'Days run', 'Groups', 'Participants', 'From', 'To']].concat(Object.keys(m).map((a) => [an(+a), m[+a].d.size, m[+a].g, m[+a].p, fd(from), fd(to)] as any[]));
    }
    if (k === 'days') {
      const r = await fetchAll(() => supabase.from('dm_day_logs').select('*').gte('date', from).lte('date', to).order('date'));
      return [['Date', 'Centre', 'DM', 'Weather state', 'Weather events', 'Avalanche', 'Closures', 'Weather notes', 'River levels', 'DM judgements and discussions']].concat(r.map((x) => [fd(x.date), cn(x.centre_id), x.dm_name, x.wx_state, x.wx_events, x.avalanche, x.closures, x.wx_notes, x.river_levels, x.dm_judgements]));
    }
    if (k === 'comms') {
      const r = await fetchAll(() => supabase.from('comms_log').select('*').gte('date', from).lte('date', to).order('date').order('time'));
      return [['Date', 'Centre', 'Time', 'Instructor', 'Entry']].concat(r.map((x) => [fd(x.date), cn(x.centre_id), hm(x.time), x.instructor_id ? nm(x.instructor_id) : 'General', x.entry]));
    }
    if (k === 'ticks') {
      const r = await fetchAll(() => supabase.from('comp_signoffs').select('*, competency_lines(content, section, element, competencies(name, level))').order('id'));
      return [['Instructor', 'Competency', 'Level', 'Section', 'Heading', 'Line', 'Tick', 'Site', 'Signed by', 'Date observed', 'Source', 'Reason', 'Recorded']].concat(
        r.map((x) => [nm(x.instructor_id), x.competency_lines?.competencies?.name, x.competency_lines?.competencies?.level, x.competency_lines?.section, x.competency_lines?.element, x.competency_lines?.content, x.tick_type, x.site, x.signed_by, fd(x.observed_on), x.source, x.reason, fd(x.created_at)]));
    }
    if (k === 'status') {
      const r = await fetchAll(() => supabase.from('v_competency_status').select('instructor_name,name,level,status,done,total').order('instructor_name').order('level').order('name'));
      return [['Instructor', 'Competency', 'Level', 'Status', 'Ticks done', 'Ticks needed']].concat(r.map((x) => [x.instructor_name, x.name, x.level, x.status, x.done, x.total]));
    }
    if (k === 'acks') {
      const r = await fetchAll(() => supabase.from('v_amp_status').select('instructor_name,title,version,signed_version,up_to_date').gt('version', 0).order('title').order('instructor_name'));
      return [['AMP', 'Current version', 'Instructor', 'Version signed', 'Up to date']].concat(r.map((x) => [x.title, x.version, x.instructor_name, x.signed_version ?? '', x.up_to_date ? 'Yes' : 'No']));
    }
    if (k === 'log') {
      const r = await fetchAll(() => supabase.from('change_log').select('*').order('changed_at'));
      return [['When', 'Who', 'About', 'What', 'Reason']].concat(r.map((x) => [new Date(x.changed_at).toLocaleString('en-NZ', { timeZone: 'Pacific/Auckland' }), x.changed_by, x.kind, x.what, x.reason]));
    }
    const q = await fetchAll(() => supabase.from('qualifications_held').select('*').order('id'));
    return [['Name', 'Initials', 'Type', 'Centre', 'Start date', 'End date', 'Qualifications held']].concat(
      base.instructors.filter((p: any) => p.account_type === 'instructor').map((p: any) => [p.name, p.initials, p.employment, cn(p.centre_id), fd(p.start_date), fd(p.end_date), q.filter((x) => x.instructor_id === p.id).map((x) => x.qualification).join(', ')]));
  }
  async function go(k: string) {
    setBusy(k); setMsg(['', '']);
    try { const rows = await build(k); downloadCsv(`hillary-${k}-${nzToday()}.csv`, rows); setMsg(['ok', `Downloaded ${rows.length - 1} rows.`]); }
    catch (e: any) { setMsg(['bad', e.message || 'Export failed.']); }
    setBusy('');
  }
  async function everything() { for (const [k] of SETS) await go(k); }

  return (
    <div className="mpanel">
      <p className="lead" style={{ marginTop: 0 }}>For audits and DOC returns. Each export downloads a spreadsheet that opens in Excel.</p>
      <div className="filters">
        <div style={{ minWidth: 140 }}><label className="f" style={{ marginTop: 0 }} htmlFor="xf">From</label><input id="xf" type="date" value={from} onChange={(e) => setFrom(e.target.value)} /></div>
        <div style={{ minWidth: 140 }}><label className="f" style={{ marginTop: 0 }} htmlFor="xt">To</label><input id="xt" type="date" value={to} onChange={(e) => setTo(e.target.value)} /></div>
        <button className="btn" onClick={everything} disabled={!!busy}>Export everything</button>
      </div>
      <div className="scroll"><table className="m" style={{ minWidth: 560 }}>
        <thead><tr><th>Record set</th><th>What is in it</th><th></th></tr></thead>
        <tbody>{SETS.map(([k, t, dsc]) => <tr key={k}><td><b>{t}</b></td><td>{dsc}</td><td><button className="btn small" disabled={!!busy} onClick={() => go(k)}>{busy === k ? 'Working…' : 'Export'}</button></td></tr>)}</tbody>
      </table></div>
      <div className={'msg ' + msg[0]}>{msg[1]}</div>
      <p className="muted" style={{ fontSize: 13 }}>"Export everything" is also a simple manual backup: run it and keep the files somewhere safe. See docs/SECURITY_AND_BACKUPS.md.</p>
    </div>
  );
}

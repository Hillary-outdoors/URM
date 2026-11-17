'use client';
import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { fd, STATUS } from '@/lib/util';
import { Pill, Picker } from '@/components/ui';

const dmName = () => { try { return localStorage.getItem('dmName') || ''; } catch (e) { return ''; } };

/**
 * Reads a CSV the way a spreadsheet wrote it: fields in quotes, commas and line breaks
 * inside them, and "" for a real quote mark. The training log is full of all three.
 */
function parseCsv(text: string): string[][] {
  const rows: string[][] = []; let row: string[] = []; let cell = ''; let quoted = false;
  const t = text.replace(/^﻿/, '').replace(/\r\n?/g, '\n');
  for (let i = 0; i < t.length; i++) {
    const ch = t[i];
    if (quoted) {
      if (ch === '"') { if (t[i + 1] === '"') { cell += '"'; i++; } else quoted = false; }
      else cell += ch;
    } else if (ch === '"') quoted = true;
    else if (ch === ',') { row.push(cell); cell = ''; }
    else if (ch === '\n') { row.push(cell); rows.push(row); row = []; cell = ''; }
    else cell += ch;
  }
  if (cell || row.length) { row.push(cell); rows.push(row); }
  return rows.filter((r) => r.some((c) => c.trim()));
}

/** "Blake Nicklin\nEliza-Jane Page" and "Bush, Cave" both mean two things. */
const bits = (s: string) => (s || '').split(/[\n;,]+/).map((x) => x.trim()).filter(Boolean);
const tidyOutcome = (s: string) => {
  const v = (s || '').trim().toLowerCase();
  if (v.startsWith('compet') || v.startsWith('compit')) return 'Competent';
  if (v.startsWith('indirect')) return 'Indirect';
  if (v.startsWith('direct')) return 'Direct';
  if (v.startsWith('monitoring')) return 'Monitoring Required';
  return s?.trim() || null;
};
const isoDate = (s: string) => {
  const v = (s || '').trim(); if (!v) return null;
  let m = v.match(/^(\d{4})-(\d{2})-(\d{2})/); if (m) return `${m[1]}-${m[2]}-${m[3]}`;
  m = v.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})/);           // NZ day first
  if (m) return `${m[3]}-${m[2].padStart(2, '0')}-${m[1].padStart(2, '0')}`;
  const d = new Date(v); return isNaN(+d) ? null : d.toISOString().slice(0, 10);
};
const norm = (s: string) => (s || '').toLowerCase().replace(/[^a-z0-9 ]/g, '').replace(/\s+/g, ' ').trim();

/** One letter different: Shephard and Shepherd are the same person. */
function close(a: string, b: string) {
  if (a === b) return true;
  if (Math.abs(a.length - b.length) > 1) return false;
  let i = 0, j = 0, slips = 0;
  while (i < a.length && j < b.length) {
    if (a[i] === b[j]) { i++; j++; continue; }
    if (++slips > 1) return false;
    if (a.length > b.length) i++; else if (b.length > a.length) j++; else { i++; j++; }
  }
  return slips + (a.length - i) + (b.length - j) <= 1;
}

/**
 * The log is typed by hand, so "Will Sinclair" and "Katrina Shephard" have to find
 * William Sinclair and Katrina Shepherd. An exact match wins; otherwise the surname must be
 * within one letter and the first names must agree as far as the shorter one goes, and it only
 * counts if exactly one person fits. Anything matched this way is shown for checking.
 */
function matchPerson(raw: string, people: any[]) {
  const n = norm(raw); if (!n) return null;
  const exact = people.find((p) => norm(p.name) === n);
  if (exact) return { person: exact, exact: true };
  const w = n.split(' '); if (w.length < 2) return null;
  // "Julian Van der put" and "Julian Vanderput" are one surname written two ways.
  const first = w[0], last = w.slice(1).join('');
  const fits = people.filter((p) => {
    const q = norm(p.name).split(' '); if (q.length < 2) return false;
    const pf = q[0], pl = q.slice(1).join('');
    const firstOk = pf === first || (Math.min(pf.length, first.length) >= 3 && (pf.startsWith(first) || first.startsWith(pf)));
    return firstOk && close(pl, last);
  });
  return fits.length === 1 ? { person: fits[0], exact: false } : null;
}

/**
 * The training log, loaded from the Smartsheet export. Loading an entry ticks its boxes: the
 * trainer already made the call when they filled the log in, so there is no second approval.
 * Loading only ever adds a tick, and every entry has an Undo.
 */
export default function TrainingLogs({ base, reload }: any) {
  const [tab, setTab] = useState('logs');
  const [logs, setLogs] = useState<any[]>([]); const [map, setMap] = useState<any[]>([]);
  const [who, setWho] = useState<string[]>([]); const [plan, setPlan] = useState<any>(null);
  const [busy, setBusy] = useState(false); const [err, setErr] = useState(''); const [done, setDone] = useState('');
  const people = base.instructors.filter((p: any) => p.account_type === 'instructor');

  const load = useCallback(async () => {
    let q = supabase.from('training_logs').select('*, training_log_comps(comp_id)').order('date', { ascending: false }).limit(400);
    if (who.length) q = q.in('instructor_id', who);
    const [l, m] = await Promise.all([q, supabase.from('log_activity_map').select('*').order('phrase')]);
    setLogs(l.data || []); setMap(m.data || []);
  }, [who]);
  useEffect(() => { load(); }, [load]);

  const nameOf = (id: string) => base.instructors.find((p: any) => p.id === id)?.name || '';
  const compOf = (id: number) => base.comps.find((c: any) => c.id === id);

  // ---------- Reading the export ----------
  async function readFile(file: File) {
    setErr(''); setDone(''); setBusy(true);
    try {
      const rows = parseCsv(await file.text());
      if (rows.length < 2) throw new Error('That file has no rows in it.');
      const head = rows[0].map((h) => norm(h));
      const col = (...names: string[]) => { for (const n of names) { const i = head.indexOf(norm(n)); if (i > -1) return i; } return -1; };
      const C = {
        date: col('Date'), centre: col('Centre'), trainer: col('Trainer'), trainee: col('Trainee'),
        days: col('Number of days', 'Total Trainee Days'), act: col('Activity/Pursuit'), loc: col('Location'),
        ttype: col('Training Type'), stype: col('Type of Session'), out: col('Outcome'),
        sum: col('Summary of session', 'Summary'), next: col('Next Steps', 'Recommended Next Steps'),
        sms: col('Followed SMS and management hazards appropriately'), folder: col('Training folder completed?', 'Folder updated'),
      };
      if (C.date < 0 || C.trainee < 0) throw new Error('I cannot find a Date and a Trainee column. Export the sheet as CSV with its header row.');

      const phrase = new Map<string, any>(); map.forEach((m) => phrase.set(norm(m.phrase), m));
      const out: any[] = []; const unknownPeople = new Set<string>(); const unknownActs = new Set<string>();
      const guessed = new Map<string, string>(); let willTick = 0;

      for (const r of rows.slice(1)) {
        const date = isoDate(r[C.date] || ''); if (!date) continue;
        const acts = C.act > -1 ? bits(r[C.act]) : [];
        let signs = false;
        acts.forEach((a) => {
          const hit = phrase.get(norm(a));
          if (!hit) { unknownActs.add(a); return; }
          if (hit.comp_name) signs = true;
        });
        const outcome = tidyOutcome(r[C.out] || '');
        for (const t of (C.trainee > -1 ? bits(r[C.trainee]) : [])) {
          const hit = matchPerson(t, people);
          if (!hit) { unknownPeople.add(t); continue; }
          const p = hit.person;
          if (!hit.exact) guessed.set(t, p.name);
          if (signs && ['Competent', 'Indirect', 'Direct'].includes(outcome || '')) willTick++;
          out.push({
            date, instructor_id: p.id, trainer: (r[C.trainer] || '').trim() || null,
            trainer_id: matchPerson(r[C.trainer] || '', base.instructors)?.person.id || null,
            centre_id: base.centres.find((c: any) => norm(c.name) === norm(r[C.centre] || ''))?.id || p.centre_id || null,
            days: C.days > -1 && r[C.days] ? Number(String(r[C.days]).replace(/[^0-9.]/g, '')) || null : null,
            activity_text: acts.join(', ') || null, location: (r[C.loc] || '').trim() || null,
            training_type: (r[C.ttype] || '').trim() || null, session_type: (r[C.stype] || '').trim() || null,
            outcome, raw_outcome: (r[C.out] || '').trim() || null,
            summary: (r[C.sum] || '').trim() || null, next_steps: (r[C.next] || '').trim() || null,
            sms_ok: (r[C.sms] || '').trim() || null, folder_updated: (r[C.folder] || '').trim() || null,
            source: 'smartsheet', imported_at: new Date().toISOString(),
            dedupe_key: [date, norm(r[C.trainer] || ''), norm(acts.join(','))].join('|').slice(0, 300),
          });
        }
      }
      setPlan({ rows: out, willTick, unknownPeople: [...unknownPeople].sort(), unknownActs: [...unknownActs].sort(), guessed: [...guessed.entries()].sort(), file: file.name });
    } catch (e: any) { setErr(e.message || 'That file could not be read.'); }
    setBusy(false);
  }

  // ---------- Loading it ----------
  async function doImport() {
    setBusy(true); setErr('');
    for (let i = 0; i < plan.rows.length; i += 200) {
      const { error } = await supabase.from('training_logs')
        .upsert(plan.rows.slice(i, i + 200), { onConflict: 'instructor_id,dedupe_key' });
      if (error) { setBusy(false); return setErr(error.message); }
    }
    // The database works out which competency and which level each entry means, and ticks.
    const { data, error } = await supabase.rpc('apply_training_logs');
    if (error) { setBusy(false); return setErr(error.message); }
    const r = Array.isArray(data) ? data[0] : data;
    await supabase.from('change_log').insert({
      kind: 'Training log', changed_by: 'Manager · ' + (dmName() || 'unnamed'),
      what: `Loaded ${plan.rows.length} log entries from ${plan.file}`,
      reason: `${r?.entries || 0} entries ticked ${r?.ticks || 0} boxes`,
    });
    setDone(`${plan.rows.length} entries loaded. ${r?.entries || 0} of them ticked ${r?.ticks || 0} boxes.`);
    setBusy(false); setPlan(null); setTab('logs'); reload?.(); load();
  }

  async function undo(log: any) {
    setBusy(true); setErr('');
    const { data, error } = await supabase.rpc('revert_training_log', { p_log: log.id });
    if (error) { setBusy(false); return setErr(error.message); }
    await supabase.from('change_log').insert({
      kind: 'Sign-off', changed_by: 'Manager · ' + (dmName() || 'unnamed'),
      what: `${nameOf(log.instructor_id)} · undid the training log entry of ${fd(log.date)} (${log.activity_text || ''}) — ${data} boxes taken back`,
      reason: 'Undone from the training log',
    });
    setBusy(false); reload?.(); load();
  }

  return (
    <div className="mpanel">
      <div className="filters">
        <div className="seg">
          <button className={tab === 'logs' ? 'on' : ''} onClick={() => setTab('logs')}>Log entries</button>
          <button className={tab === 'import' ? 'on' : ''} onClick={() => setTab('import')}>Load from Smartsheet</button>
          <button className={tab === 'map' ? 'on' : ''} onClick={() => setTab('map')}>What each activity means</button>
        </div>
        {tab === 'logs' && <div style={{ minWidth: 260 }}>
          <label className="f" style={{ marginTop: 0 }}>Instructor</label>
          <Picker options={people.map((x: any) => ({ id: x.id, label: x.name }))} value={who} onChange={setWho} placeholder="Everyone" />
        </div>}
      </div>

      {done && <div className="hl">{done}</div>}

      {tab === 'logs' && (logs.length ? <div className="scroll"><table className="m">
        <thead><tr><th>Date</th><th>Instructor</th><th>Trainer</th><th>Activity</th><th>Outcome</th><th>What it ticked</th><th></th></tr></thead>
        <tbody>{logs.map((l) => {
          const comps = (l.training_log_comps || []).map((x: any) => compOf(x.comp_id)).filter(Boolean);
          return <tr key={l.id}>
            <td>{fd(l.date)}</td><td><b>{nameOf(l.instructor_id)}</b></td><td>{l.trainer || ''}</td>
            <td>{l.activity_text || ''}{l.location ? <><br /><small className="muted">{l.location}</small></> : null}</td>
            <td>{l.outcome ? <Pill kind={STATUS[l.outcome] || 'mute'}>{l.outcome}</Pill> : ''}</td>
            <td>{comps.length
              ? <>{comps.map((c: any) => <span key={c.id} style={{ marginRight: 6 }}><Pill kind="good">{c.name} L{c.level}</Pill></span>)}
                  <small className="muted">{l.ticks_made || 0} boxes</small></>
              : <small className="muted">{['Competent', 'Indirect', 'Direct'].includes(l.outcome) ? 'nothing left to tick' : 'recorded only'}</small>}</td>
            <td>{l.ticks_made ? <button className="btn small" disabled={busy} onClick={() => undo(l)}>Undo</button> : null}</td>
          </tr>;
        })}</tbody>
      </table></div> : <p className="muted">No log entries yet. Load the Smartsheet export under "Load from Smartsheet".</p>)}

      {tab === 'import' && <div className="card" style={{ maxWidth: 700 }}>
        <h3>Load the training log</h3>
        <p className="muted" style={{ fontSize: 13.5 }}>
          In Smartsheet: <b>File › Export › Export to CSV</b>, then pick that file here. Loading an entry
          ticks its boxes, with the trainer on the entry as the signer and their initials in each box.
          Competent ticks every box, Indirect the Self and Observation boxes, Direct the Self box.
          Anything else is kept as a record and ticks nothing.
        </p>
        <p className="muted" style={{ fontSize: 13.5 }}>
          Loading only ever adds a tick, so the same export can be loaded every day and an old entry can
          never undo a later sign-off. Where a competency exists at two levels, the lowest one the person
          has not finished is the one that gets ticked. Each entry has an Undo.
        </p>
        <input type="file" accept=".csv,text/csv" onChange={(e) => { const f = e.target.files?.[0]; if (f) readFile(f); }} />
        <div className="msg bad">{err}</div>
        {plan && <>
          <h3 style={{ marginTop: 14 }}>{plan.rows.length} entries ready</h3>
          <p className="muted" style={{ fontSize: 13.5 }}>
            About {plan.willTick} of them will tick boxes; the rest load as a record.
            {plan.unknownPeople.length ? ` ${plan.unknownPeople.length} names are not on the instructor list and will be skipped: ${plan.unknownPeople.join(', ')}.` : ''}
          </p>
          {plan.guessed.length > 0 && <div className="hl">
            <b>Spelled differently on the log.</b> I have treated these as the same person — check them:
            {' '}{plan.guessed.map(([a, b]: [string, string]) => `"${a}" → ${b}`).join(' · ')}.
          </div>}
          {plan.unknownActs.length > 0 && <div className="hl">
            <b>{plan.unknownActs.length} activity names have no competency yet:</b> {plan.unknownActs.join(' · ')}.
            <br />These entries load as a record and tick nothing. Point them at a competency under "What each
            activity means" and load the file again to pick them up.
          </div>}
          <button className="btn primary" disabled={busy} onClick={doImport}>{busy ? 'Loading…' : `Load ${plan.rows.length} entries`}</button>
        </>}
      </div>}

      {tab === 'map' && <MapTab base={base} map={map} reload={load} />}
    </div>
  );
}

/** Points a phrase from the log at a competency. */
function MapTab({ base, map, reload }: any) {
  const [n, setN] = useState({ phrase: '', comp_name: '', level: '' });
  const names = [...new Set(base.comps.map((c: any) => c.name))].sort() as string[];
  return (
    <div style={{ maxWidth: 700 }}>
      <p className="muted" style={{ fontSize: 13.5 }}>
        The log says "Winter Alpine"; the competency is called "Alpine Winter". This is that list. A
        phrase with no competency is still recorded — it just ticks nothing, which is right for things
        like Induction or Lesson Planning. Leave the level as "whichever they are working on" unless a
        phrase can only ever mean one level.
      </p>
      <div className="rowflex" style={{ marginBottom: 10 }}>
        <input type="text" style={{ flex: 1, minWidth: 140 }} placeholder="As written on the log" aria-label="Phrase" value={n.phrase} onChange={(e) => setN({ ...n, phrase: e.target.value })} />
        <select style={{ flex: 1, minWidth: 160 }} aria-label="Competency" value={n.comp_name} onChange={(e) => setN({ ...n, comp_name: e.target.value })}>
          <option value="">Records only, ticks nothing</option>
          {names.map((x) => <option key={x} value={x}>{x}</option>)}
        </select>
        <select style={{ width: 150 }} aria-label="Level" value={n.level} onChange={(e) => setN({ ...n, level: e.target.value })}>
          <option value="">Whichever they are on</option>
          {[1, 2, 3, 4].map((x) => <option key={x} value={x}>Level {x} only</option>)}
        </select>
        <button className="btn small" onClick={async () => {
          if (!n.phrase.trim()) return;
          await supabase.from('log_activity_map').upsert({ phrase: n.phrase.trim().toLowerCase(), comp_name: n.comp_name || null, level: n.level ? +n.level : null });
          setN({ phrase: '', comp_name: '', level: '' }); reload();
        }}>Add</button>
      </div>
      <div className="scroll"><table className="m">
        <thead><tr><th>On the log</th><th>Competency</th><th>Level</th><th>Note</th><th></th></tr></thead>
        <tbody>{map.map((m: any) => (
          <tr key={m.phrase}><td>{m.phrase}</td>
            <td>{m.comp_name || <small className="muted">records only</small>}</td>
            <td>{m.level ? 'L' + m.level : <small className="muted">whichever</small>}</td>
            <td><small className="muted">{m.note || ''}</small></td>
            <td><button className="btn small" onClick={async () => { await supabase.from('log_activity_map').delete().eq('phrase', m.phrase); reload(); }}>×</button></td></tr>
        ))}</tbody>
      </table></div>
    </div>
  );
}

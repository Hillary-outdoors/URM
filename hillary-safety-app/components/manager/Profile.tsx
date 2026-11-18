'use client';
import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { nzToday, fd, STATUS } from '@/lib/util';
import { Pill, StatusPill, Picker, Modal, TickGrid, TICKS, tickName } from '@/components/ui';
import FolderPrint from './FolderPrint';

const dmName = () => { try { return localStorage.getItem('dmName') || ''; } catch (e) { return ''; } };
const logChange = (what: string, reason: string, by: string) => supabase.from('change_log').insert({ kind: 'Sign-off', what, reason, changed_by: 'Manager · ' + (by || 'unnamed') });

/** One instructor: summary on top, then a competency's full line list to sign off. */
export default function Profile({ base }: any) {
  const people = base.instructors.filter((p: any) => p.account_type === 'instructor');
  const [pid, setPid] = useState<string>(''); const [stat, setStat] = useState<any[]>([]); const [quals, setQuals] = useState<any[]>([]);
  const [cid, setCid] = useState<number>(0); const [lines, setLines] = useState<any[]>([]); const [ticks, setTicks] = useState<Record<string, any>>({}); const [ampSigned, setAmpSigned] = useState(false);
  const [form, setForm] = useState<any>(null); const [nq, setNq] = useState({ qualification: '', awarded_on: '', expires_on: '' }); const [err, setErr] = useState('');
  const [printing, setPrinting] = useState(false);
  // The one-off job of copying the paper folders in. While it is on, a click ticks straight away
  // using the initials and date set at the top, with no form in between.
  const [fc, setFc] = useState<any>({ on: false, ini: '', date: '', busy: false });
  const p = people.find((x: any) => x.id === pid);

  const loadPerson = useCallback(async () => {
    if (!pid) return;
    const [s, q] = await Promise.all([
      supabase.from('v_competency_status').select('*').eq('instructor_id', pid).order('level').order('name'),
      supabase.from('qualifications_held').select('*').eq('instructor_id', pid).order('qualification'),
    ]);
    setStat(s.data || []); setQuals(q.data || []);
  }, [pid]);
  const loadComp = useCallback(async () => {
    if (!pid || !cid) { setLines([]); return; }
    const { data: ls } = await supabase.from('competency_lines').select('*').eq('comp_id', cid).order('sort_order').order('id');
    // Ask for this person's ticks on this competency, rather than listing two thousand line
    // numbers in the web address. Same answer, one indexed lookup, a URL that fits.
    const { data: so } = (ls || []).length
      ? await supabase.from('comp_signoffs').select('*, competency_lines!inner(comp_id)')
          .eq('instructor_id', pid).eq('competency_lines.comp_id', cid)
      : { data: [] as any[] };
    const act = base.comps.find((c: any) => c.id === cid)?.act_id;
    const { data: am } = act ? await supabase.from('v_amp_status').select('signed_version').eq('instructor_id', pid).eq('act_id', act).maybeSingle() : { data: null as any };
    setLines(ls || []); setTicks(Object.fromEntries((so || []).map((s: any) => [s.line_id + '|' + s.tick_type, s]))); setAmpSigned(!!am?.signed_version);
  }, [pid, cid, base.comps]);
  useEffect(() => { loadPerson(); setCid(0); }, [loadPerson]);
  useEffect(() => { loadComp(); }, [loadComp]);
  const refresh = () => { loadPerson(); loadComp(); };

  const comp = stat.find((s) => s.comp_id === cid);
  const mine = stat.filter((s) => !s.centre_id || !p?.centre_id || s.centre_id === p.centre_id);
  const levels = [1, 2, 3, 4].map((lv) => ({ lv, all: mine.filter((s) => s.level === lv) })).filter((x) => x.all.length);
  const current = levels.find((x) => x.all.some((s) => s.status !== 'Competent')) || levels[levels.length - 1];

  const autoIni = (n: string) => (n || '').split(/[ -]+/).filter(Boolean).map((w) => w[0]).join('').toUpperCase().slice(0, 3);
  // Anyone on the staff list can be the signer, managers included. The initials that go in the
  // box come from their own record, so nobody types them and two people never share a pair.
  const staff = base.instructors.filter((x: any) => x.employment !== 'Past staff');
  const signer = (name: string) => staff.find((x: any) => x.name === name);
  const iniOf = (name: string) => (signer(name)?.initials || autoIni(name) || '').toUpperCase().slice(0, 3);
  /** Copy a box straight off the paper: no form, no reason, marked as coming from the folder. */
  async function folderTick(l: any, type: string, on: boolean) {
    setErr('');
    const key = l.id + '|' + type;
    if (on) {
      const row = ticks[key];
      setTicks((t: any) => { const n = { ...t }; delete n[key]; return n; });     // show it at once
      const { error } = await supabase.from('comp_signoffs').delete()
        .eq('instructor_id', pid).eq('line_id', l.id).eq('tick_type', type);
      if (error) { setTicks((t: any) => ({ ...t, [key]: row })); setErr(error.message); return; }
    } else {
      const row = {
        instructor_id: pid, line_id: l.id, tick_type: type, source: 'folder',
        signed_by: 'From the paper folder', initials: (fc.ini || '').toUpperCase().slice(0, 3) || null,
        observed_on: fc.date || null,
      };
      setTicks((t: any) => ({ ...t, [key]: row }));
      const { error } = await supabase.from('comp_signoffs').upsert(row, { onConflict: 'instructor_id,line_id,tick_type' });
      if (error) { setTicks((t: any) => { const n = { ...t }; delete n[key]; return n; }); setErr(error.message); return; }
    }
    loadPerson();                                   // the status pill follows along
  }

  /** Fill a whole column down the page - the usual shape of a folder, one assessor on one visit. */
  async function fillColumn(type: string) {
    setErr(''); setFc({ ...fc, busy: true });
    const rows = lines.filter((l: any) => !l.auto_from_amp && l['needs_' + type] && !ticks[l.id + '|' + type])
      .map((l: any) => ({
        instructor_id: pid, line_id: l.id, tick_type: type, source: 'folder',
        signed_by: 'From the paper folder', initials: (fc.ini || '').toUpperCase().slice(0, 3) || null,
        observed_on: fc.date || null,
      }));
    if (rows.length) {
      const { error } = await supabase.from('comp_signoffs').upsert(rows, { onConflict: 'instructor_id,line_id,tick_type' });
      if (error) { setFc({ ...fc, busy: false }); return setErr(error.message); }
    }
    setFc({ ...fc, busy: false }); loadComp(); loadPerson();
  }

  function clickTick(l: any, type: string, on: boolean) {
    if (fc.on) return folderTick(l, type, on);
    setErr('');
    if (on) setForm({ mode: 'remove', l, type, tick: ticks[l.id + '|' + type], reason: '', by: dmName() });
    else setForm({ mode: 'add', l, type, by: dmName(), ini: iniOf(dmName()), date: nzToday(), site: '', based: 'Observed in person', note: '', all: false });
  }
  async function submit() {
    const f = form, who = p.name + ' · ' + comp.name + ' (L' + comp.level + ')';
    if (f.mode === 'remove') {
      if (f.reason.trim().length < 5) return setErr('Give a short reason.');
      const { error } = await supabase.from('comp_signoffs').delete().eq('id', f.tick.id); if (error) return setErr(error.message);
      await logChange(`${who} · removed ${tickName(f.type, comp?.box_labels)} tick on "${f.l.content}"`, f.reason, f.by);
    } else if (f.mode === 'add') {
      const site = f.type.startsWith('assess');
      if (!f.by.trim() || !(f.ini || '').trim() || f.note.trim().length < 5 || (site && !f.site.trim())) return setErr('Pick who signed it off' + (site ? ', fill in the site' : '') + ' and add a short note.');
      const need = 'needs_' + f.type;
      const targets = f.all ? lines.filter((x) => x.element === f.l.element && x.section === f.l.section && !x.auto_from_amp && x[need] && !ticks[x.id + '|' + f.type]) : [f.l];
      const { error } = await supabase.from('comp_signoffs').upsert(targets.map((x) => ({
        instructor_id: pid, line_id: x.id, tick_type: f.type, site: f.site || null, signed_by: f.by, initials: f.ini.trim().toUpperCase(), observed_on: f.date,
        source: f.based === 'Training log' ? 'training_log' : 'manual', reason: f.based + ': ' + f.note,
      })), { onConflict: 'instructor_id,line_id,tick_type' });
      if (error) return setErr(error.message);
      await logChange(`${who} · ${tickName(f.type, comp?.box_labels)} signed off on ${targets.length > 1 ? targets.length + ' lines under "' + f.l.element + '"' : '"' + f.l.content + '"'}${f.site ? ' at ' + f.site : ''} (${f.based}, ${fd(f.date)})`, f.note, f.by);
    } else {
      if (!f.by.trim() || f.reason.trim().length < 5) return setErr('Fill in who is signing off and the reason.');
      const rows: any[] = [];
      lines.filter((l) => !l.auto_from_amp).forEach((l) => TICKS.forEach((t) => {
        if (l['needs_' + t] && !ticks[l.id + '|' + t]) rows.push({ instructor_id: pid, line_id: l.id, tick_type: t, signed_by: f.by, initials: iniOf(f.by), observed_on: nzToday(), source: 'override', reason: f.reason });
      }));
      if (rows.length) { const { error } = await supabase.from('comp_signoffs').upsert(rows, { onConflict: 'instructor_id,line_id,tick_type' }); if (error) return setErr(error.message); }
      await logChange(`${who} · whole competency signed off by manager override (${rows.length} boxes ticked)`, f.reason, f.by);
    }
    setForm(null); refresh();
  }
  async function addQual() {
    if (!nq.qualification.trim()) return;
    await supabase.from('qualifications_held').insert({ instructor_id: pid, qualification: nq.qualification.trim(), awarded_on: nq.awarded_on || null, expires_on: nq.expires_on || null, checked_by: dmName() || null });
    setNq({ qualification: '', awarded_on: '', expires_on: '' }); loadPerson();
  }
  const f = form, setF = (k: string, v: any) => setForm({ ...form, [k]: v });

  if (printing && p) return <FolderPrint person={p} onClose={() => setPrinting(false)} />;

  return (
    <div className="mpanel">
      <div className="filters"><div style={{ minWidth: 300 }}><label className="f" style={{ marginTop: 0 }}>Instructor</label>
        <Picker single options={people.map((x: any) => ({ id: x.id, label: x.name + (x.employment !== 'Staff' ? ' · ' + x.employment : '') }))} value={pid ? [pid] : []} onChange={(v) => setPid(v[0])} placeholder="Search for an instructor…" /></div>
        {p && <button className="btn" style={{ alignSelf: 'center' }} onClick={() => setPrinting(true)}>Print folder</button>}
        {p && <button className={'btn' + (fc.on ? ' primary' : '')} style={{ alignSelf: 'center' }}
          onClick={() => setFc({ ...fc, on: !fc.on })}>{fc.on ? 'Folder check: on' : 'Folder check'}</button>}</div>
      {err && !form && <div className="msg bad" style={{ marginTop: 8 }}>
        {err}<button className="linkish" style={{ float: 'right' }} onClick={() => setErr('')}>dismiss</button>
      </div>}
      {p && fc.on && (
        <div className="hl" style={{ marginTop: 0 }}>
          <b>Copying the paper folder in.</b> Clicking a box ticks it straight away — no form, no reason.
          Click it again to take it off. Set the initials and date from the page you are reading and they
          go on every box until you change them; leave them blank if the folder does not say.
          <div className="rowflex" style={{ gap: 8, marginTop: 8, alignItems: 'flex-end' }}>
            <div style={{ width: 110 }}><label className="f" style={{ marginTop: 0 }} htmlFor="fci">Initials</label>
              <input id="fci" type="text" maxLength={3} value={fc.ini}
                onChange={(e) => setFc({ ...fc, ini: e.target.value.toUpperCase() })} placeholder="GS" /></div>
            <div style={{ width: 170 }}><label className="f" style={{ marginTop: 0 }} htmlFor="fcd">Date on the page</label>
              <input id="fcd" type="date" value={fc.date} onChange={(e) => setFc({ ...fc, date: e.target.value })} /></div>
            {comp && <div className="rowflex" style={{ gap: 6 }}>
              {TICKS.filter((t) => lines.some((l: any) => l['needs_' + t] && !l.auto_from_amp)).map((t) => (
                <button key={t} className="btn small" disabled={fc.busy} onClick={() => fillColumn(t)}>
                  Fill {tickName(t, comp.box_labels)}
                </button>
              ))}
            </div>}
          </div>
        </div>
      )}
      {!p ? <p className="muted">Search for an instructor to see their profile. Add new instructors under Edit › Instructors.</p> : (
        <>
          <div className="sum">
            <div className="card"><span className="muted">Level</span>
              {current ? <><h3>{current.all.every((s) => s.status === 'Competent') ? 'Level ' + current.lv + ' complete' : 'Working towards Level ' + current.lv}</h3>
                <div>{current.all.filter((s) => s.status === 'Competent').length} of {current.all.length} competencies Competent</div>
                <div className="bar"><i style={{ width: (current.all.filter((s) => s.status === 'Competent').length / current.all.length) * 100 + '%' }} /></div></> : <h3>No competencies set up</h3>}
              <small className="muted">{p.employment} · {base.centres.find((c: any) => c.id === p.centre_id)?.name || 'No centre'}{p.start_date ? ' · started ' + fd(p.start_date) : ''}</small></div>
            <div className="card"><span className="muted">Qualifications held</span>
              <div style={{ marginTop: 4 }}>{quals.length ? quals.map((q) => (
                <div key={q.id} className="rowflex" style={{ marginBottom: 4 }}><Pill>{q.qualification}</Pill><small className="muted">{[q.awarded_on && 'awarded ' + fd(q.awarded_on), q.expires_on && 'expires ' + fd(q.expires_on)].filter(Boolean).join(' · ')}</small>
                  <button className="btn small" aria-label={'Remove ' + q.qualification} onClick={async () => { await supabase.from('qualifications_held').delete().eq('id', q.id); loadPerson(); }}>×</button></div>
              )) : 'None recorded'}</div>
              <div className="rowflex" style={{ marginTop: 8 }}>
                <input type="text" style={{ flex: 1, minWidth: 140 }} placeholder="Add, e.g. NZOIA Bush 1" aria-label="Qualification" value={nq.qualification} onChange={(e) => setNq({ ...nq, qualification: e.target.value })} />
                <input type="date" style={{ width: 150 }} aria-label="Expiry date" title="Expiry date (optional)" value={nq.expires_on} onChange={(e) => setNq({ ...nq, expires_on: e.target.value })} />
                <button className="btn small" onClick={addQual}>Add</button></div></div>
            <div className="card"><span className="muted">Competent on</span>
              <div style={{ marginTop: 4 }}>{mine.filter((s) => s.status === 'Competent').map((s) => <span key={s.comp_id} style={{ margin: '2px 4px 2px 0', display: 'inline-block' }}><Pill kind="good">{s.name} L{s.level}</Pill></span>)}{!mine.some((s) => s.status === 'Competent') && 'Nothing yet'}</div>
              <span className="muted" style={{ display: 'block', marginTop: 8 }}>In progress</span>
              <div>{mine.filter((s) => s.status === 'Indirect' || s.status === 'Direct').map((s) => <span key={s.comp_id} style={{ margin: '2px 4px 2px 0', display: 'inline-block' }}><Pill kind={STATUS[s.status]}>{s.name} L{s.level} · {s.status}</Pill></span>)}{!mine.some((s) => s.status === 'Indirect' || s.status === 'Direct') && 'None'}</div></div>
          </div>
          <div className="filters">
            <div style={{ minWidth: 260 }}><label className="f" style={{ marginTop: 0 }} htmlFor="pc">Competency</label>
              <select id="pc" value={cid} onChange={(e) => setCid(+e.target.value)}><option value={0}>Choose a competency…</option>{mine.map((s) => <option key={s.comp_id} value={s.comp_id}>{s.name} (L{s.level}) · {s.status}</option>)}</select></div>
            {comp && <div className="rowflex" style={{ alignSelf: 'center' }}><StatusPill status={comp.status} /><Pill>{comp.done} of {comp.total} ticks</Pill>
              {comp.status !== 'Competent' && <button className="btn small" onClick={() => { setErr(''); setForm({ mode: 'override', by: dmName(), reason: '' }); }}>Sign off whole competency</button>}</div>}
          </div>
          {comp && <><p className="muted" style={{ margin: '0 0 6px', maxWidth: '70ch' }}>
            {fc.on
              ? 'Folder check is on: a click ticks or unticks the box straight away and records it as copied from the paper folder.'
              : 'Click an empty box to sign it off. Click a ticked box to remove it. Both ask for a reason and go in the change log.'}</p>
            <div style={{ maxWidth: 760 }}>{lines.length ? <TickGrid labels={comp.box_labels} lines={lines} has={(l, t) => (l.auto_from_amp ? ampSigned : !!ticks[l.id + '|' + t])} canClick={(l) => !l.auto_from_amp} onClick={clickTick}
              ini={(l, t) => ticks[l.id + '|' + t]?.initials || ''}
              hint={(l, t) => { const s = ticks[l.id + '|' + t]; return s ? `${s.initials ? s.initials + ' · ' : ''}${s.signed_by || 'Self'}${s.observed_on ? ' · ' + fd(s.observed_on) : ''}${s.site ? ' · ' + s.site : ''}${s.reason ? '\n' + s.reason : ''}` : 'Click to sign off'; }} /> : <span className="muted">No lines yet. Add them under Edit › Competencies.</span>}</div></>}
        </>
      )}
      <Modal open={!!f}>
        {f && <>
          <h3>{f.mode === 'remove' ? 'Remove ' + tickName(f.type, comp?.box_labels) + ' tick' : f.mode === 'add' ? 'Sign off: ' + tickName(f.type, comp?.box_labels) : 'Sign off whole competency'}</h3>
          <div className="muted">{p?.name} · {comp?.name} (L{comp?.level})</div>
          {f.l && <div className="hl" style={{ margin: '8px 0' }}>{f.l.content}</div>}
          {f.mode === 'remove' && f.tick && <small className="muted">Signed by {f.tick.signed_by || 'the instructor (Self)'}{f.tick.observed_on ? ' on ' + fd(f.tick.observed_on) : ''}. {f.tick.reason}</small>}
          {f.mode === 'override' && <div className="hl" style={{ margin: '8px 0' }}>This ticks every remaining box on this competency and makes {p?.name} Competent. Use it for Recognition of Current Competence or when records exist elsewhere.</div>}
          <div className="grid2">
            <div><label className="f">{f.mode === 'remove' ? 'Your name' : 'Signed off by'}</label>
              <Picker single options={staff.map((x: any) => ({ id: x.name, label: x.name + (x.initials ? ' (' + x.initials + ')' : '') }))} value={f.by ? [f.by] : []}
                onChange={(v) => setForm({ ...form, by: v[0] || '', ini: iniOf(v[0] || '') })} placeholder="Search for the person signing…" />
              {f.mode === 'add' && f.by && <small className="muted">{f.ini} goes in the box</small>}</div>
            {f.mode === 'add' && <div><label className="f" htmlFor="sfd">Date observed</label><input id="sfd" type="date" max={nzToday()} value={f.date} onChange={(e) => setF('date', e.target.value)} /></div>}
          </div>
          {f.mode === 'add' && <>
            {f.type.startsWith('assess') && <><label className="f" htmlFor="sfs">Site</label><input id="sfs" type="text" value={f.site} onChange={(e) => setF('site', e.target.value)} placeholder="For example: Tama Lakes" /></>}
            <label className="f" htmlFor="sfe">Based on</label><select id="sfe" value={f.based} onChange={(e) => setF('based', e.target.value)}><option>Observed in person</option><option>Training log</option><option>Recognition of Current Competence</option></select>
            <label className="f" htmlFor="sfn">Notes (required)</label><textarea id="sfn" rows={2} value={f.note} onChange={(e) => setF('note', e.target.value)} placeholder="What you saw, or which log or qualification this is based on" />
            <div className="check"><input type="checkbox" id="sfa" checked={f.all} onChange={(e) => setF('all', e.target.checked)} style={{ width: 18, height: 18 }} /><label htmlFor="sfa">Also tick {tickName(f.type, comp?.box_labels)} for every other line under "{f.l.element}"</label></div>
          </>}
          {f.mode !== 'add' && <><label className="f" htmlFor="sfr">Reason (required)</label><textarea id="sfr" rows={3} value={f.reason} onChange={(e) => setF('reason', e.target.value)} /></>}
          <div className="err">{err}</div>
          <div className="acts"><button className="btn" onClick={() => setForm(null)}>Cancel</button><button className="btn primary" onClick={submit}>{f.mode === 'remove' ? 'Remove tick' : 'Sign off'}</button></div>
        </>}
      </Modal>
    </div>
  );
}

'use client';
import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { fd } from '@/lib/util';
import { Pill } from '@/components/ui';

const F: [string, string, number][] = [
  ['title', 'Title', 0], ['folder', 'Folder', 0], ['activity_number', 'Activity number', 0], ['location', 'Location', 0], ['activity_description', 'Activity description', 1],
  ['emergency_response', 'Emergency response', 0], ['instructor_requirements', 'Instructor requirements', 0], ['client_competencies', 'Client competencies', 0],
  ['specific_equipment', 'Specific equipment required', 0], ['specific_policies', 'Specific policies', 0], ['access_permission', 'Access permission required?', 0],
  ['camping', 'Camping', 0], ['toilets', 'Toilets', 0], ['water', 'Water', 0], ['key_hazards', 'Key hazards', 0], ['other_resources', 'Other resources and notes', 1], ['previous_incidents', 'Previous incidents', 1],
];
const dmName = () => { try { return localStorage.getItem('dmName') || ''; } catch (e) { return ''; } };

/** Write and publish AMPs. Publishing a new version asks everyone to sign again. */
export default function Amps({ base, reload }: any) {
  const [id, setId] = useState<number>(0); const [amp, setAmp] = useState<any>(null); const [act, setAct] = useState<any>(null);
  const [haz, setHaz] = useState<any[]>([]); const [acks, setAcks] = useState<any[]>([]);
  const [change, setChange] = useState(''); const [by, setBy] = useState(''); const [msg, setMsg] = useState<[string, string]>(['', '']); const [newTitle, setNewTitle] = useState('');

  const load = useCallback(async () => {
    if (!id) { setAmp(null); return; }
    const { data: a } = await supabase.from('amps').select('*').eq('id', id).single();
    if (!a) return;
    const [h, k, ac] = await Promise.all([
      supabase.from('amp_hazards').select('*').eq('amp_id', id).order('sort_order'),
      supabase.from('v_amp_status').select('instructor_id,instructor_name,up_to_date').eq('amp_id', id).order('instructor_name').limit(2000),
      supabase.from('activities').select('*').eq('id', a.act_id).single(),
    ]);
    setAmp(Object.fromEntries(Object.entries(a).map(([k2, v]) => [k2, v ?? '']))); setHaz(h.data || []); setAcks(k.data || []); setAct(ac.data); setChange(''); setBy(dmName());
  }, [id]);
  useEffect(() => { load(); setMsg(['', '']); }, [load]);

  async function create() {
    const t = newTitle.trim(); if (!t) return;
    const { data: a, error } = await supabase.from('activities').insert({ name: t }).select().single();
    if (error) return setMsg(['bad', error.message.includes('duplicate') ? 'There is already an activity with that name.' : error.message]);
    const { data: m, error: e2 } = await supabase.from('amps').insert({ act_id: a.id, title: t }).select().single();
    if (e2) return setMsg(['bad', e2.message]);
    setNewTitle(''); await reload(); setId(m.id);
  }
  async function saveFlag(patch: any) { setAct({ ...act, ...patch }); await supabase.from('activities').update(patch).eq('id', act.id); reload(); }
  async function publish() {
    if (change.trim().length < 5) return setMsg(['bad', 'Say what changed, so instructors know what to look for.']);
    if (!by.trim()) return setMsg(['bad', 'Add your name.']);
    const fields: any = {}; F.forEach(([k]) => (fields[k] = amp[k] || null));
    if (!fields.title) return setMsg(['bad', 'The AMP needs a title.']);
    const v = (+amp.version || 0) + 1;
    const { error } = await supabase.from('amps').update({ ...fields, version: v, change_summary: change.trim(), updated_by: by.trim(), updated_at: new Date().toISOString() }).eq('id', id);
    if (error) return setMsg(['bad', error.message]);
    await supabase.from('activities').update({ name: fields.title }).eq('id', amp.act_id);
    await supabase.from('amp_hazards').delete().eq('amp_id', id);
    const rows = haz.filter((h) => h.hazard || h.management_strategy || h.activity_part).map((h, n) => ({ amp_id: id, sort_order: n, control: h.control || null, activity_part: h.activity_part || null, hazard: h.hazard || null, management_strategy: h.management_strategy || null }));
    if (rows.length) await supabase.from('amp_hazards').insert(rows);
    await supabase.from('change_log').insert({ kind: 'AMP', what: `AMP ${fields.title} published as version ${v}`, reason: change.trim(), changed_by: 'Manager · ' + by.trim() });
    await reload(); await load(); setMsg(['ok', `Published version ${v}. Everyone will be asked to sign it.`]);
  }
  const setH = (n: number, k: string, v: string) => setHaz(haz.map((h, i) => (i === n ? { ...h, [k]: v } : h)));
  const yes = acks.filter((a) => a.up_to_date), no = acks.filter((a) => !a.up_to_date);

  return (
    <div className="mpanel">
      <div className="filters">
        <div style={{ minWidth: 260 }}><label className="f" style={{ marginTop: 0 }} htmlFor="ea">AMP</label>
          <select id="ea" value={id} onChange={(e) => setId(+e.target.value)}><option value={0}>Choose an AMP…</option>{base.amps.map((a: any) => <option key={a.id} value={a.id}>{a.title} (v{a.version})</option>)}</select></div>
        <div><label className="f" style={{ marginTop: 0 }} htmlFor="nt">New AMP</label><input id="nt" type="text" value={newTitle} onChange={(e) => setNewTitle(e.target.value)} placeholder="Activity name" /></div>
        <button className="btn" onClick={create}>+ Create</button>
        {amp && <div style={{ marginLeft: 'auto', alignSelf: 'center' }}><Pill>{+amp.version ? `Current version ${amp.version} · ${fd(amp.updated_at)}` : 'Not published yet'}</Pill></div>}
      </div>
      <div className={'msg ' + msg[0]}>{msg[1]}</div>
      {!amp ? <p className="muted">Choose an AMP to edit, or create a new one. Instructors only see AMPs that have been published.</p> : (
        <>
          {act && <div className="filters">
            <div><label className="f" style={{ marginTop: 0 }} htmlFor="ecall">Call-in type</label><select id="ecall" value={act.call_in_type} onChange={(e) => saveFlag({ call_in_type: e.target.value })}>{['None', 'Cave', 'Water', 'Mountain'].map((o) => <option key={o}>{o}</option>)}</select></div>
            <div><label className="f" style={{ marginTop: 0 }} htmlFor="epark">Inside the national park (DOC report)</label><select id="epark" value={act.in_national_park ? 'Yes' : 'No'} onChange={(e) => saveFlag({ in_national_park: e.target.value === 'Yes' })}><option>No</option><option>Yes</option></select></div>
            <div><label className="f" style={{ marginTop: 0 }} htmlFor="eact">Shown to instructors</label><select id="eact" value={act.active ? 'Yes' : 'No'} onChange={(e) => saveFlag({ active: e.target.value === 'Yes' })}><option>Yes</option><option>No</option></select></div>
            <div className="muted" style={{ alignSelf: 'center', fontSize: 13, maxWidth: '40ch' }}>These three save straight away. Call-in activities are timed and alarmed.</div>
          </div>}
          <div className="sum">
            <div className="card"><span className="muted">Acknowledged version {amp.version} · {yes.length} of {acks.length}</span><div style={{ marginTop: 4 }}>{yes.map((a) => <span key={a.instructor_id} style={{ margin: '2px 4px 2px 0', display: 'inline-block' }}><Pill kind="good">{a.instructor_name}</Pill></span>)}{!yes.length && <span className="muted">Nobody yet</span>}</div></div>
            <div className="card"><span className="muted">Yet to acknowledge · {no.length}</span><div style={{ marginTop: 4 }}>{no.map((a) => <span key={a.instructor_id} style={{ margin: '2px 4px 2px 0', display: 'inline-block' }}><Pill kind="bad">{a.instructor_name}</Pill></span>)}{!no.length && <span className="muted">Nobody</span>}</div></div>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(260px,1fr))', gap: '0 16px' }}>
            {F.map(([k, l, wide]) => (
              <div key={k} style={wide ? { gridColumn: '1 / -1' } : undefined}><label className="f" htmlFor={'af-' + k}>{l}</label>
                {wide ? <textarea id={'af-' + k} rows={3} value={amp[k]} onChange={(e) => setAmp({ ...amp, [k]: e.target.value })} /> : <input id={'af-' + k} type="text" value={amp[k]} onChange={(e) => setAmp({ ...amp, [k]: e.target.value })} />}</div>
            ))}
          </div>
          <label className="f">Safety management lines (control, activity, hazard, management strategy)</label>
          {haz.map((h, n) => (
            <div className="hazrow" key={n}>
              <select aria-label="Control" value={h.control || ''} onChange={(e) => setH(n, 'control', e.target.value)}><option value="">Control…</option><option>Eliminate</option><option>Isolate</option><option>Minimise</option></select>
              <input type="text" aria-label="Activity" placeholder="Activity" value={h.activity_part || ''} onChange={(e) => setH(n, 'activity_part', e.target.value)} />
              <input type="text" aria-label="Hazard" placeholder="Hazard" value={h.hazard || ''} onChange={(e) => setH(n, 'hazard', e.target.value)} />
              <input type="text" aria-label="Management strategy" placeholder="Management strategy" value={h.management_strategy || ''} onChange={(e) => setH(n, 'management_strategy', e.target.value)} />
              <button className="btn small" aria-label="Remove line" onClick={() => setHaz(haz.filter((_, i) => i !== n))}>×</button>
            </div>
          ))}
          <button className="btn small" onClick={() => setHaz([...haz, { control: 'Minimise' }])}>+ Add line</button>
          <div className="grid2" style={{ marginTop: 10 }}>
            <div><label className="f" htmlFor="ech">What changed in this version (instructors see this highlighted)</label><textarea id="ech" rows={2} value={change} onChange={(e) => setChange(e.target.value)} /></div>
            <div><label className="f" htmlFor="eby">Your name</label><input id="eby" type="text" value={by} onChange={(e) => setBy(e.target.value)} /></div>
          </div>
          <p className="muted" style={{ fontSize: 13 }}>Nothing on this page is saved until you publish. Publishing makes a new version and asks every instructor to sign again.</p>
          <button className="btn primary" onClick={publish}>Publish as version {(+amp.version || 0) + 1}</button>
        </>
      )}
    </div>
  );
}

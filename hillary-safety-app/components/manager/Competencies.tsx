'use client';
import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { STATUS } from '@/lib/util';
import { Pill } from '@/components/ui';

const SECTIONS = ['Technical Competence', 'Group Management and Leadership', 'Instruction', 'SMS'];
const HEAD: [string, string][] = [['scope', 'Scope'], ['prerequisites', 'Prerequisites'], ['assessment', 'Observation and assessment'], ['rcc_rule', 'Recognition of Current Competence']];
const NEEDS: [string, string][] = [['needs_self', 'Self'], ['needs_obs1', 'Obs1'], ['needs_assess1', 'Site1'], ['needs_assess2', 'Site2']];

/** Set up competencies and their lines. Edits save as you go. */
export default function Competencies({ base, reload }: any) {
  const [id, setId] = useState<number>(0); const [c, setC] = useState<any>(null); const [lines, setLines] = useState<any[]>([]); const [stat, setStat] = useState<any[]>([]);
  const [nc, setNc] = useState({ name: '', level: '1' }); const [nl, setNl] = useState({ section: SECTIONS[0], element: '', content: '' }); const [msg, setMsg] = useState<[string, string]>(['', '']);

  const load = useCallback(async () => {
    if (!id) { setC(null); return; }
    const [a, l, s] = await Promise.all([
      supabase.from('competencies').select('*').eq('id', id).single(),
      supabase.from('competency_lines').select('*').eq('comp_id', id).order('sort_order').order('id'),
      supabase.from('v_competency_status').select('instructor_id,instructor_name,status').eq('comp_id', id).order('instructor_name').limit(2000),
    ]);
    setC(a.data ? Object.fromEntries(Object.entries(a.data).map(([k, v]) => [k, v ?? ''])) : null); setLines(l.data || []); setStat(s.data || []);
  }, [id]);
  useEffect(() => { load(); setMsg(['', '']); }, [load]);

  async function create() {
    if (!nc.name.trim()) return;
    const { data, error } = await supabase.from('competencies').insert({ name: nc.name.trim(), level: +nc.level }).select().single();
    if (error) return setMsg(['bad', error.message]);
    setNc({ name: '', level: '1' }); await reload(); setId(data.id);
  }
  async function saveC(patch: any) {
    setC({ ...c, ...patch });
    const clean: any = {}; Object.entries(patch).forEach(([k, v]) => (clean[k] = v === '' ? null : v));
    const { error } = await supabase.from('competencies').update(clean).eq('id', id);
    if (error) setMsg(['bad', error.message]); else if (patch.name !== undefined || patch.level !== undefined || patch.act_id !== undefined) reload();
  }
  async function saveL(l: any, patch: any) {
    setLines(lines.map((x) => (x.id === l.id ? { ...x, ...patch } : x)));
    const { error } = await supabase.from('competency_lines').update(patch).eq('id', l.id);
    if (error) setMsg(['bad', error.message]);
  }
  async function addLine() {
    if (!nl.content.trim()) return;
    const max = lines.reduce((m, x) => Math.max(m, x.sort_order), 0);
    const { error } = await supabase.from('competency_lines').insert({ comp_id: id, section: nl.section, element: nl.element.trim(), content: nl.content.trim(), sort_order: max + 10 });
    if (error) return setMsg(['bad', error.message]);
    setNl({ ...nl, content: '' }); load();
  }
  async function delLine(l: any) {
    if (!window.confirm('Delete this line? Any ticks people have on it are deleted too.')) return;
    await supabase.from('competency_lines').delete().eq('id', l.id); load();
  }
  async function move(l: any, dir: number) {
    const i = lines.findIndex((x) => x.id === l.id), j = i + dir; if (j < 0 || j >= lines.length) return;
    const next = [...lines]; [next[i], next[j]] = [next[j], next[i]];
    setLines(next.map((x, n) => ({ ...x, sort_order: (n + 1) * 10 })));
    await Promise.all(next.map((x, n) => supabase.from('competency_lines').update({ sort_order: (n + 1) * 10 }).eq('id', x.id)));
  }

  return (
    <div className="mpanel">
      <div className="filters">
        <div style={{ minWidth: 260 }}><label className="f" style={{ marginTop: 0 }} htmlFor="ec">Competency</label>
          <select id="ec" value={id} onChange={(e) => setId(+e.target.value)}><option value={0}>Choose a competency…</option>{base.comps.map((x: any) => <option key={x.id} value={x.id}>{x.name} (L{x.level})</option>)}</select></div>
        <div><label className="f" style={{ marginTop: 0 }} htmlFor="ncn">New competency</label><input id="ncn" type="text" value={nc.name} onChange={(e) => setNc({ ...nc, name: e.target.value })} placeholder="For example: Alpine Summer" /></div>
        <div style={{ minWidth: 90 }}><label className="f" style={{ marginTop: 0 }} htmlFor="ncl">Level</label><select id="ncl" value={nc.level} onChange={(e) => setNc({ ...nc, level: e.target.value })}>{[1, 2, 3, 4].map((n) => <option key={n}>{n}</option>)}</select></div>
        <button className="btn" onClick={create}>+ Create</button>
      </div>
      <div className={'msg ' + msg[0]}>{msg[1]}</div>
      {!c ? <p className="muted">Choose a competency to edit, or create a new one.</p> : (
        <>
          <div className="sum">{['Competent', 'Indirect', 'Direct', 'Not started'].map((s) => {
            const l = stat.filter((x) => x.status === s);
            return <div className="card" key={s}><span className="muted">{s} · {l.length}</span><div style={{ marginTop: 4 }}>{l.map((x) => <span key={x.instructor_id} style={{ margin: '2px 4px 2px 0', display: 'inline-block' }}><Pill kind={STATUS[s]}>{x.instructor_name}</Pill></span>)}{!l.length && <span className="muted">Nobody</span>}</div></div>;
          })}</div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(200px,1fr))', gap: '0 14px' }}>
            <div><label className="f" htmlFor="cn">Name</label><input id="cn" type="text" value={c.name} onChange={(e) => setC({ ...c, name: e.target.value })} onBlur={(e) => saveC({ name: e.target.value })} /></div>
            <div><label className="f" htmlFor="cl">Level</label><select id="cl" value={c.level} onChange={(e) => saveC({ level: +e.target.value })}>{[1, 2, 3, 4].map((n) => <option key={n} value={n}>{n}</option>)}</select></div>
            <div><label className="f" htmlFor="ca">Activity it unlocks</label><select id="ca" value={c.act_id} onChange={(e) => saveC({ act_id: e.target.value ? +e.target.value : '' })}><option value="">None</option>{base.activities.map((a: any) => <option key={a.id} value={a.id}>{a.name}</option>)}</select></div>
            <div><label className="f" htmlFor="cc">Centre</label><select id="cc" value={c.centre_id} onChange={(e) => saveC({ centre_id: e.target.value ? +e.target.value : '' })}><option value="">Both</option>{base.centres.map((x: any) => <option key={x.id} value={x.id}>{x.name}</option>)}</select></div>
            <div><label className="f" htmlFor="cv">Version</label><input id="cv" type="text" value={c.version} onChange={(e) => setC({ ...c, version: e.target.value })} onBlur={(e) => saveC({ version: e.target.value })} placeholder="2024, version 9" /></div>
          </div>
          {HEAD.map(([k, l]) => <div key={k}><label className="f" htmlFor={'cf-' + k}>{l}</label><textarea id={'cf-' + k} rows={2} value={c[k]} onChange={(e) => setC({ ...c, [k]: e.target.value })} onBlur={(e) => saveC({ [k]: e.target.value })} /></div>)}
          <p className="muted" style={{ fontSize: 13 }}>The activity link is what the intention check uses: someone is "Competent for Kayaking" when they are Competent on the lowest-level competency linked to Kayaking.</p>

          <h3 style={{ fontSize: 16, margin: '18px 0 2px' }}>Lines ({lines.length})</h3>
          <p className="muted" style={{ margin: '0 0 8px' }}>Edit the wording, or untick a box to grey it out for that line. "Auto" means the line ticks itself when the person has signed the activity's AMP.</p>
          <div className="scroll"><div style={{ minWidth: 760 }}>
            <div className="lineedit" style={{ gridTemplateColumns: '150px 170px 1fr repeat(5,40px) 96px' }}>
              <span className="lehead" style={{ textAlign: 'left' }}>Section</span><span className="lehead" style={{ textAlign: 'left' }}>Heading</span><span className="lehead" style={{ textAlign: 'left' }}>Line</span>
              {NEEDS.map(([, l]) => <span className="lehead" key={l}>{l}</span>)}<span className="lehead">Auto</span><span />
            </div>
            {lines.map((l) => (
              <div className="lineedit" key={l.id} style={{ gridTemplateColumns: '150px 170px 1fr repeat(5,40px) 96px' }}>
                <select aria-label="Section" value={l.section} onChange={(e) => saveL(l, { section: e.target.value })}>{[...new Set([...SECTIONS, l.section])].map((s) => <option key={s}>{s}</option>)}</select>
                <input type="text" aria-label="Heading" defaultValue={l.element} onBlur={(e) => e.target.value !== l.element && saveL(l, { element: e.target.value })} />
                <input type="text" aria-label="Line text" defaultValue={l.content} onBlur={(e) => e.target.value !== l.content && e.target.value.trim() && saveL(l, { content: e.target.value })} />
                {NEEDS.map(([k, lab]) => <input key={k} type="checkbox" aria-label={lab + ' required'} checked={l[k]} onChange={(e) => saveL(l, { [k]: e.target.checked })} />)}
                <input type="checkbox" aria-label="Ticks itself from the AMP" checked={l.auto_from_amp} onChange={(e) => saveL(l, { auto_from_amp: e.target.checked })} />
                <span className="rowflex" style={{ gap: 3 }}><button className="btn small" aria-label="Move up" onClick={() => move(l, -1)}>↑</button><button className="btn small" aria-label="Move down" onClick={() => move(l, 1)}>↓</button><button className="btn small" aria-label="Delete line" onClick={() => delLine(l)}>×</button></span>
              </div>
            ))}
          </div></div>
          <div className="filters" style={{ marginTop: 16 }}>
            <div><label className="f" style={{ marginTop: 0 }} htmlFor="nls">Section</label><select id="nls" value={nl.section} onChange={(e) => setNl({ ...nl, section: e.target.value })}>{SECTIONS.map((s) => <option key={s}>{s}</option>)}</select></div>
            <div><label className="f" style={{ marginTop: 0 }} htmlFor="nle">Heading</label><input id="nle" type="text" value={nl.element} onChange={(e) => setNl({ ...nl, element: e.target.value })} placeholder="1. Demonstrate navigation skills" /></div>
            <div style={{ flex: 1, minWidth: 240 }}><label className="f" style={{ marginTop: 0 }} htmlFor="nlt">New line</label><input id="nlt" type="text" value={nl.content} onChange={(e) => setNl({ ...nl, content: e.target.value })} onKeyDown={(e) => { if (e.key === 'Enter') addLine(); }} placeholder="Wording of the line" /></div>
            <button className="btn primary" onClick={addLine}>Add line</button>
          </div>
        </>
      )}
    </div>
  );
}

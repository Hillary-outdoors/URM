'use client';
import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

/**
 * Merging, splitting and de-duplicating competencies.
 *
 * All three rest on the same fact: a tick is stored against a line, not against a competency. So a
 * line that changes hands takes its ticks with it, and everybody's Competent / Indirect / Direct is
 * recalculated from the ticks by the database. Nothing here has to touch a status directly.
 *
 * The one real decision is a duplicate line — two lines that say the same thing, one of which is
 * about to go. Whoever is doing it says whether the surviving line keeps those ticks.
 */

/** The same flattening the database uses, so the preview agrees with what the merge will do. */
const norm = (s: string) => (s || '').replace(/[^a-z0-9 ]/gi, ' ').toLowerCase().replace(/\s+/g, ' ').trim();

type Tab = 'merge' | 'split' | 'dups';

export default function CompTools({ base, reload }: any) {
  const [tab, setTab] = useState<Tab>('merge');
  const [msg, setMsg] = useState<[string, string]>(['', '']);
  const [keepTicks, setKeepTicks] = useState(true);

  const comps = [...base.comps].sort((a: any, b: any) => a.level - b.level || a.name.localeCompare(b.name));
  const label = (c: any) => `${c.name} (L${c.level})`;
  const after = async (m: string) => { setMsg(['ok', m]); await reload(); };

  return (
    <div className="mpanel" style={{ marginBottom: 14 }}>
      <div className="filters" style={{ marginBottom: 8 }}>
        <h3 style={{ fontSize: 16, alignSelf: 'center', margin: 0 }}>Tidying up the competencies</h3>
        <div><div className="seg">
          {([['merge', 'Merge two'], ['split', 'Split one'], ['dups', 'Repeated lines']] as [Tab, string][]).map(([k, l]) => (
            <button key={k} className={tab === k ? 'on' : ''} onClick={() => { setTab(k); setMsg(['', '']); }}>{l}</button>
          ))}
        </div></div>
      </div>

      <div className="hl" style={{ marginTop: 0 }}>
        <label className="f" style={{ marginTop: 0 }}>When two lines say the same thing and one has to go</label>
        <div className="rowflex" style={{ gap: 14, flexWrap: 'wrap' }}>
          <label className="check" style={{ gap: 6 }}>
            <input type="radio" checked={keepTicks} onChange={() => setKeepTicks(true)} />
            <span>The surviving line keeps the ticks</span>
          </label>
          <label className="check" style={{ gap: 6 }}>
            <input type="radio" checked={!keepTicks} onChange={() => setKeepTicks(false)} />
            <span>Those ticks go — it has to be observed again</span>
          </label>
        </div>
        <small className="muted">
          Only affects lines that duplicate one another. Every other line carries its ticks across either way.
        </small>
      </div>

      <div className={'msg ' + msg[0]}>{msg[1]}</div>

      {tab === 'merge' && <Merge comps={comps} label={label} keepTicks={keepTicks} onDone={after} onErr={(m: string) => setMsg(['bad', m])} />}
      {tab === 'split' && <Split comps={comps} label={label} onDone={after} onErr={(m: string) => setMsg(['bad', m])} />}
      {tab === 'dups' && <Dups keepTicks={keepTicks} onDone={after} onErr={(m: string) => setMsg(['bad', m])} />}
    </div>
  );
}

/* ------------------------------------------------------------------ merge */

function Merge({ comps, label, keepTicks, onDone, onErr }: any) {
  const [keep, setKeep] = useState(0); const [absorb, setAbsorb] = useState(0);
  const [prev, setPrev] = useState<any>(null); const [busy, setBusy] = useState(false);

  useEffect(() => {
    let off = false;
    if (!keep || !absorb || keep === absorb) { setPrev(null); return; }
    (async () => {
      const { data } = await supabase.from('competency_lines').select('id,comp_id,content')
        .in('comp_id', [keep, absorb]);
      if (off) return;
      const k = (data || []).filter((l: any) => l.comp_id === keep);
      const a = (data || []).filter((l: any) => l.comp_id === absorb);
      const kn = new Set(k.map((l: any) => norm(l.content)));
      const dup = a.filter((l: any) => kn.has(norm(l.content)));
      const { count } = await supabase.from('comp_signoffs').select('id', { count: 'exact', head: true })
        .in('line_id', dup.map((l: any) => l.id).length ? dup.map((l: any) => l.id) : [-1]);
      if (!off) setPrev({ keepLines: k.length, absorbLines: a.length, dup: dup.length, dupTicks: count || 0, samples: dup.slice(0, 4) });
    })();
    return () => { off = true; };
  }, [keep, absorb]);

  const kc = comps.find((c: any) => c.id === keep), ac = comps.find((c: any) => c.id === absorb);

  async function go() {
    if (!kc || !ac) return;
    if (!window.confirm(`Fold "${label(ac)}" into "${label(kc)}"?\n\n${label(ac)} will no longer exist. This cannot be undone from the app.`)) return;
    setBusy(true);
    const { data, error } = await supabase.rpc('merge_competencies', { p_keep: keep, p_absorb: absorb, p_keep_ticks: keepTicks });
    setBusy(false);
    if (error) return onErr(error.message);
    const r = Array.isArray(data) ? data[0] : data;
    setAbsorb(0); setPrev(null);
    onDone(`Merged. ${r.moved} line${r.moved === 1 ? '' : 's'} moved across, ${r.merged} folded into a line that already said the same thing, ${r.ticks_moved} tick${r.ticks_moved === 1 ? '' : 's'} carried over, ${r.ticks_dropped} dropped.`);
  }

  return (
    <>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(240px,1fr))', gap: '0 16px' }}>
        <div><label className="f" htmlFor="mk">Keep this one</label>
          <select id="mk" value={keep} onChange={(e) => setKeep(+e.target.value)}>
            <option value={0}>Choose…</option>{comps.map((c: any) => <option key={c.id} value={c.id}>{label(c)}</option>)}
          </select></div>
        <div><label className="f" htmlFor="ma">Fold this one into it</label>
          <select id="ma" value={absorb} onChange={(e) => setAbsorb(+e.target.value)}>
            <option value={0}>Choose…</option>
            {comps.filter((c: any) => c.id !== keep).map((c: any) => <option key={c.id} value={c.id}>{label(c)}</option>)}
          </select></div>
      </div>

      {prev && (
        <div className="card" style={{ marginTop: 12 }}>
          <b style={{ fontSize: 14 }}>What will happen</b>
          <ul style={{ margin: '6px 0 0', paddingLeft: 18, fontSize: 13.5 }}>
            <li><b>{prev.absorbLines - prev.dup}</b> line{prev.absorbLines - prev.dup === 1 ? '' : 's'} move across with every tick on them, untouched.</li>
            <li><b>{prev.dup}</b> line{prev.dup === 1 ? '' : 's'} already said on <i>{label(kc)}</i>, so {prev.dup === 1 ? 'it is' : 'they are'} folded into the one that is there.</li>
            <li><b>{prev.dupTicks}</b> tick{prev.dupTicks === 1 ? '' : 's'} sit on {prev.dup === 1 ? 'that duplicate line' : 'those duplicate lines'} — {keepTicks ? 'these move onto the surviving line, except where the person already holds that box.' : 'these go, and those boxes have to be observed again.'}</li>
            <li><i>{label(kc)}</i> ends up with roughly <b>{prev.keepLines + prev.absorbLines - prev.dup}</b> lines. <i>{label(ac)}</i> stops existing.</li>
          </ul>
          {prev.samples.length > 0 && <>
            <small className="muted" style={{ display: 'block', marginTop: 8 }}>Lines it thinks are the same:</small>
            {prev.samples.map((s: any) => <div key={s.id} style={{ fontSize: 13 }}>· {s.content}</div>)}
            {prev.dup > prev.samples.length && <small className="muted">…and {prev.dup - prev.samples.length} more.</small>}
          </>}
          <button className="btn primary" style={{ marginTop: 10 }} disabled={busy} onClick={go}>
            {busy ? 'Merging…' : `Fold ${label(ac)} into ${label(kc)}`}
          </button>
        </div>
      )}
      {!prev && <p className="muted" style={{ marginBottom: 0 }}>Pick two competencies and it will show you what the merge does before anything happens.</p>}
    </>
  );
}

/* ------------------------------------------------------------------ split */

function Split({ comps, label, onDone, onErr }: any) {
  const [from, setFrom] = useState(0);
  const [lines, setLines] = useState<any[]>([]);
  const [take, setTake] = useState<Set<number>>(new Set());
  const [name, setName] = useState(''); const [level, setLevel] = useState('1'); const [code, setCode] = useState('');
  const [busy, setBusy] = useState(false);

  const load = useCallback(async () => {
    if (!from) { setLines([]); setTake(new Set()); return; }
    const { data } = await supabase.from('competency_lines')
      .select('id,section,element,content,sort_order').eq('comp_id', from).order('sort_order').order('id');
    setLines(data || []); setTake(new Set());
    const c = comps.find((x: any) => x.id === from);
    if (c) setLevel(String(c.level));
  }, [from, comps]);
  useEffect(() => { load(); }, [load]);

  const fc = comps.find((c: any) => c.id === from);
  const toggle = (id: number) => setTake((p) => { const n = new Set(p); if (n.has(id)) n.delete(id); else n.add(id); return n; });

  async function go() {
    if (!fc || !take.size || !name.trim()) return;
    if (take.size === lines.length) return onErr('That would move every line. Leave at least one behind, or rename the competency instead.');
    if (!window.confirm(`Move ${take.size} line${take.size === 1 ? '' : 's'} out of "${label(fc)}" into a new competency "${name.trim()}"?\n\nThe ticks on those lines come with them.`)) return;
    setBusy(true);
    const { error } = await supabase.rpc('split_competency', {
      p_from: from, p_name: name.trim(), p_level: +level,
      p_code: code.trim() || null, p_lines: [...take],
    });
    setBusy(false);
    if (error) return onErr(error.message);
    const n = take.size;
    setName(''); setCode(''); await load();
    onDone(`Split done. ${n} line${n === 1 ? '' : 's'} now sit on "${name.trim()}", with every tick that was on them.`);
  }

  let sec = '';
  return (
    <>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(200px,1fr))', gap: '0 16px' }}>
        <div><label className="f" htmlFor="sf">Split this one</label>
          <select id="sf" value={from} onChange={(e) => setFrom(+e.target.value)}>
            <option value={0}>Choose…</option>{comps.map((c: any) => <option key={c.id} value={c.id}>{label(c)}</option>)}
          </select></div>
        <div><label className="f" htmlFor="sn">Name of the new one</label>
          <input id="sn" type="text" value={name} onChange={(e) => setName(e.target.value)} placeholder="For example: Alpine Winter Camp" /></div>
        <div style={{ maxWidth: 110 }}><label className="f" htmlFor="sl">Level</label>
          <select id="sl" value={level} onChange={(e) => setLevel(e.target.value)}>{[1, 2, 3, 4].map((n) => <option key={n}>{n}</option>)}</select></div>
        <div><label className="f" htmlFor="sc">Code (optional)</label>
          <input id="sc" type="text" value={code} onChange={(e) => setCode(e.target.value)} placeholder="TL2-07" /></div>
      </div>

      {!from ? <p className="muted" style={{ marginBottom: 0 }}>Choose a competency and tick the lines that should move to the new one.</p> : (
        <>
          <div className="rowflex" style={{ margin: '12px 0 4px', gap: 8, flexWrap: 'wrap' }}>
            <b style={{ fontSize: 14 }}>{take.size} of {lines.length} lines moving</b>
            <button className="btn small" onClick={() => setTake(new Set(lines.map((l) => l.id)))}>All</button>
            <button className="btn small" onClick={() => setTake(new Set())}>None</button>
          </div>
          <div style={{ maxHeight: 360, overflow: 'auto', border: '1px solid var(--line)', borderRadius: 6, padding: 8 }}>
            {lines.map((l) => {
              const newSec = l.section !== sec; sec = l.section;
              return (
                <span key={l.id} style={{ display: 'contents' }}>
                  {newSec && <div className="sec">{l.section}</div>}
                  <label className="check" style={{ gap: 8, alignItems: 'flex-start', padding: '2px 0' }}>
                    <input type="checkbox" checked={take.has(l.id)} onChange={() => toggle(l.id)} style={{ width: 17, height: 17, marginTop: 2 }} />
                    <span style={{ fontSize: 13.5 }}>{l.element ? <small className="muted">{l.element} · </small> : null}{l.content}</span>
                  </label>
                </span>
              );
            })}
            {!lines.length && <span className="muted">No lines on this competency.</span>}
          </div>
          <button className="btn primary" style={{ marginTop: 10 }} disabled={busy || !take.size || !name.trim()} onClick={go}>
            {busy ? 'Splitting…' : `Move ${take.size} line${take.size === 1 ? '' : 's'} to a new competency`}
          </button>
          <p className="muted" style={{ fontSize: 12.5, margin: '6px 0 0' }}>
            The lines move rather than being copied, so nobody loses a tick — whoever was signed off on a
            line is signed off on it in its new home.
          </p>
        </>
      )}
    </>
  );
}

/* ------------------------------------------------------------------ repeated lines */

function Dups({ keepTicks, onDone, onErr }: any) {
  const [rows, setRows] = useState<any[]>([]);
  const [all, setAll] = useState<any[]>([]);
  const [hidden, setHidden] = useState<Set<string>>(new Set());
  const [dest, setDest] = useState<Record<string, number>>({});   // chosen home, per wording
  const [busy, setBusy] = useState('');
  const [load0, setLoad0] = useState(true);

  const load = useCallback(async () => {
    setLoad0(true);
    const [d, c] = await Promise.all([
      supabase.from('v_duplicate_lines').select('*').order('copies', { ascending: false }).limit(400),
      supabase.from('competencies').select('id,name,level,required_for_all').order('level').order('name'),
    ]);
    setRows(d.data || []); setAll(c.data || []); setLoad0(false);
  }, []);
  useEffect(() => { load(); }, [load]);

  // Look a competency up by id. The view's two lists come back in different orders, so the name
  // has to come from here rather than from lining the arrays up against each other.
  const nameOf = (id: number) => { const c = all.find((x: any) => x.id === id); return c ? `${c.name} L${c.level}` : 'competency ' + id; };
  const core = all.filter((c: any) => c.required_for_all);

  /**
   * Say this line once, in the competency chosen. If that competency already has a copy, that one
   * stays and the rest go. If it does not, one is moved there first — ticks and all — and then the
   * rest go. One path covers both, which matters when a wording has 33 copies and a button for each
   * would be unusable.
   */
  async function sayItIn(g: any, compId: number) {
    const { data: ls } = await supabase.from('competency_lines').select('id,comp_id').in('id', g.line_ids);
    if (!ls || !ls.length) return onErr('Those lines have changed since this list was drawn. Reload and try again.');
    let keepLine = ls.find((l: any) => l.comp_id === compId);
    const dest = nameOf(compId);
    const others = ls.filter((l: any) => l.id !== (keepLine?.id ?? ls[0].id)).length;
    if (!window.confirm(`Say this line once, in ${dest}?\n\n${keepLine ? 'The copy there stays' : 'A copy moves there'} and ${others} other cop${others === 1 ? 'y is' : 'ies are'} removed.`)) return;

    setBusy(g.norm);
    if (!keepLine) {
      keepLine = ls[0];
      const { error } = await supabase.rpc('move_line', { p_line: keepLine.id, p_comp: compId });
      if (error) { setBusy(''); return onErr(error.message); }
    }
    const drop = ls.filter((l: any) => l.id !== keepLine!.id).map((l: any) => l.id);
    let r: any = { dropped: 0, ticks_moved: 0, ticks_dropped: 0 };
    if (drop.length) {
      const { data, error } = await supabase.rpc('resolve_duplicate', { p_keep_line: keepLine.id, p_drop_lines: drop, p_move_ticks: keepTicks });
      if (error) { setBusy(''); return onErr(error.message); }
      r = Array.isArray(data) ? data[0] : data;
    }
    setBusy('');
    await load();
    onDone(`Now said once, in ${dest}. ${r.dropped} other cop${r.dropped === 1 ? 'y' : 'ies'} removed, ${r.ticks_moved} tick${r.ticks_moved === 1 ? '' : 's'} carried over, ${r.ticks_dropped} dropped.`);
  }

  const shown = rows.filter((r) => !hidden.has(r.norm));

  if (load0) return <p className="muted">Looking for repeated wording…</p>;
  if (!rows.length) return <p className="muted" style={{ marginBottom: 0 }}>No line is worded the same way in two different competencies.</p>;

  return (
    <>
      <p className="muted" style={{ fontSize: 13.5 }}>
        {rows.length} wording{rows.length === 1 ? '' : 's'} appear{rows.length === 1 ? 's' : ''} in more than one competency
        {hidden.size ? ` · ${hidden.size} set aside for now` : ''}. Some of these genuinely belong in every
        competency and some only need saying once — only you can tell which, so nothing happens until you say so.
      </p>
      {shown.map((g) => (
        <div className="card" key={g.norm} style={{ margin: '0 0 8px' }}>
          <div style={{ fontSize: 14 }}><b>{g.sample}</b></div>
          <small className="muted">{g.copies} cop{g.copies === 1 ? 'y' : 'ies'} · {g.where_it_is}</small>
          <div className="rowflex" style={{ gap: 6, marginTop: 8, flexWrap: 'wrap', alignItems: 'center' }}>
            <span style={{ fontSize: 13.5 }}>Say it once, in</span>
            <select aria-label="Where this line should live" style={{ minWidth: 220, maxWidth: 320 }}
              value={dest[g.norm] ?? (core[0]?.id || g.comp_ids?.[0] || 0)}
              onChange={(e) => setDest((p) => ({ ...p, [g.norm]: +e.target.value }))}>
              {/* The competencies it is already in first, then everything else. */}
              <optgroup label="Where it is now">
                {(g.comp_ids || []).map((cid: number) => <option key={cid} value={cid}>{nameOf(cid)}</option>)}
              </optgroup>
              <optgroup label="Anywhere else">
                {all.filter((c: any) => !(g.comp_ids || []).includes(c.id))
                  .map((c: any) => <option key={c.id} value={c.id}>{c.name} L{c.level}{c.required_for_all ? ' · core' : ''}</option>)}
              </optgroup>
            </select>
            <button className="btn small primary" disabled={busy === g.norm}
              onClick={() => sayItIn(g, dest[g.norm] ?? (core[0]?.id || g.comp_ids?.[0] || 0))}>
              {busy === g.norm ? 'Working…' : 'Do it'}
            </button>
            <button className="btn small" onClick={() => setHidden((p) => new Set([...p, g.norm]))}>Leave it in all of them</button>
          </div>
        </div>
      ))}
      {hidden.size > 0 && <button className="btn small" onClick={() => setHidden(new Set())}>Show the {hidden.size} set aside</button>}
    </>
  );
}

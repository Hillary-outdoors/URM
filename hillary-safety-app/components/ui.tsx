'use client';
import { useState } from 'react';
import { STATUS, Checks } from '@/lib/util';

export const Pill = ({ kind = 'mute', children }: any) => <span className={'pill ' + kind}>{children}</span>;
export const StatusPill = ({ status }: { status?: string }) =>
  status ? <Pill kind={STATUS[status] || 'mute'}>{status}</Pill> : <Pill>No competency set</Pill>;

/** Search-and-pick box. Type a few letters, tap a match. Chosen items show as chips. */
export function Picker({ options, value, onChange, placeholder, single }: {
  options: { id: any; label: string }[]; value: any[]; onChange: (v: any[]) => void; placeholder: string; single?: boolean;
}) {
  const [q, setQ] = useState(''); const [open, setOpen] = useState(false);
  const matches = options.filter((o) => !value.includes(o.id) && (!q || o.label.toLowerCase().includes(q.toLowerCase()))).slice(0, 8);
  const label = (id: any) => options.find((o) => o.id === id)?.label || '?';
  return (
    <div className="picker">
      <div className="sel">
        {value.map((id) => (
          <button type="button" key={id} className="chip on" onClick={() => { if (!single) onChange(value.filter((x) => x !== id)); }}>
            {label(id)}{single ? '' : ' ×'}
          </button>
        ))}
      </div>
      <input type="text" value={q} placeholder={placeholder} aria-label={placeholder} autoComplete="off"
        onChange={(e) => { setQ(e.target.value); setOpen(true); }} onFocus={() => setOpen(true)} onBlur={() => setTimeout(() => setOpen(false), 150)} />
      <div className={'pkl' + (open ? ' on' : '')}>
        {matches.length ? matches.map((o) => (
          <button type="button" key={o.id} onMouseDown={(e) => { e.preventDefault(); onChange(single ? [o.id] : [...value, o.id]); setQ(''); setOpen(false); }}>{o.label}</button>
        )) : <div style={{ padding: '8px 10px' }} className="muted">No match</div>}
      </div>
    </div>
  );
}

/** Tap-to-add common phrases under a text box. */
export const Quick = ({ items, onPick }: { items: string[]; onPick: (t: string) => void }) => (
  <div className="quick">{items.map((t) => <button type="button" key={t} onClick={() => onPick(t)}>+ {t}</button>)}</div>
);

/** Panel that slides in from the right. */
export const Sheet = ({ open, onClose, children }: any) => (
  <div className={'sheet' + (open ? ' on' : '')} onMouseDown={(e) => { if (e.target === e.currentTarget) onClose(); }}>
    <div className="box">{open ? children : null}</div>
  </div>
);
/** Small box in the middle of the screen. */
export const Modal = ({ open, children }: any) => (
  <div className={'sform' + (open ? ' on' : '')} role="dialog" aria-modal="true"><div className="box">{open ? children : null}</div></div>
);

const TYPES: [string, string, string][] = [['self', 'needs_self', 'Self'], ['obs1', 'needs_obs1', 'Obs1'], ['assess1', 'needs_assess1', 'Site1'], ['assess2', 'needs_assess2', 'Site2']];
export const TICK_NAME: Record<string, string> = { self: 'Self', obs1: 'Obs 1', assess1: 'Site 1', assess2: 'Site 2' };

/**
 * The competency folder page: one row per line, four boxes per row.
 * Grey = not required. Green = ticked. `canClick` decides which boxes are buttons.
 */
export function TickGrid({ lines, has, canClick, onClick, hint }: {
  lines: any[]; has: (line: any, type: string) => boolean; canClick: (line: any, type: string) => boolean;
  onClick: (line: any, type: string, on: boolean) => void; hint?: (line: any, type: string) => string;
}) {
  let sec = '', el = '';
  return (
    <div>
      {lines.map((l) => {
        const newSec = l.section !== sec, newEl = l.element !== el || newSec; sec = l.section; el = l.element;
        return (
          <div key={l.id}>
            {newSec && <div className="sec">{l.section}</div>}
            {newEl && <><div className="el">{l.element}</div><div className="tkhead">{TYPES.map((t) => <span key={t[0]}>{t[2]}</span>)}</div></>}
            <div className="ln">
              <span className="tx">{l.content}{l.auto_from_amp && <> <Pill>auto</Pill></>}</span>
              <span className="ticks">
                {TYPES.map(([type, need]) => {
                  if (!l[need]) return <span key={type} className="tk na" title="Not required" />;
                  const on = has(l, type);
                  return canClick(l, type)
                    ? <button type="button" key={type} className={'tk' + (on ? ' on' : '')} title={hint?.(l, type)} aria-label={TICK_NAME[type] + (on ? ' ticked' : ' not ticked')} onClick={() => onClick(l, type, on)}>{on ? '✓' : ''}</button>
                    : <span key={type} className={'tk ro' + (on ? ' on' : '')} title={l.auto_from_amp ? 'Ticks itself when the AMP is acknowledged' : 'Ticked by a manager'}>{on ? '✓' : ''}</span>;
                })}
              </span>
            </div>
          </div>
        );
      })}
    </div>
  );
}

/** Who-can-run-what grid: instructors down the side, activities across the top. */
export function Matrix({ who, acts, checks }: { who: any[]; acts: any[]; checks: Checks }) {
  if (!who.length || !acts.length) return null;
  return (
    <div className="scroll">
      <table className="mx">
        <thead><tr><th></th>{acts.map((a) => <th key={a.id}>{a.name}</th>)}</tr></thead>
        <tbody>
          {who.map((w) => (
            <tr key={w.id}><th>{w.name}</th>
              {acts.map((a) => {
                const k = w.id + '|' + a.id, amp = checks.amp[k];
                return <td key={a.id}><StatusPill status={checks.comp[k]} />
                  <small className={amp ? 'okc' : 'noc'}>{amp === undefined ? 'No AMP yet' : amp ? '✓ AMP signed' : '✗ AMP not signed'}</small></td>;
              })}
            </tr>
          ))}
          <tr><th>Covered?</th>
            {acts.map((a) => {
              const st = who.map((w) => checks.comp[w.id + '|' + a.id]).filter(Boolean);
              const c = !st.length || st.includes('Competent'), k = who.every((w) => checks.amp[w.id + '|' + a.id] !== false);
              return <td key={a.id}><b className={c && k ? 'okc' : 'noc'}>{c && k ? 'Yes' : !c ? 'No Competent instructor' : 'AMP signatures missing'}</b></td>;
            })}
          </tr>
        </tbody>
      </table>
    </div>
  );
}

export const Field = ({ label, children, wide }: any) => (
  <div style={wide ? { gridColumn: '1 / -1' } : undefined}><label className="f">{label}</label>{children}</div>
);

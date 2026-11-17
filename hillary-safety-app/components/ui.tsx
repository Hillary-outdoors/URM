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
  // show a good scrollable run of the list, not just the first few
  const hits = options.filter((o) => !value.includes(o.id) && (!q || o.label.toLowerCase().includes(q.toLowerCase())));
  const matches = hits.slice(0, 60);
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
        {hits.length > matches.length && <div style={{ padding: '6px 10px' }} className="muted">…and {hits.length - matches.length} more — type to narrow it down</div>}
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

/** The six kinds of box a competency line can have, in the order they are shown. */
export const TICKS = ['self', 'obs1', 'obs2', 'assess1', 'assess2', 'assess3'] as const;
export const TICK_NAME: Record<string, string> = { self: 'Self', obs1: 'Obs 1', obs2: 'Obs 2', assess1: 'Assessor', assess2: 'Assessor 2', assess3: 'Assessor 3' };
/** The name printed on the paper form for a box (each competency has its own), or the standard name. */
export const tickName = (type: string, labels?: Record<string, string> | null) => (labels && labels[type]) || TICK_NAME[type] || type;

/**
 * The competency folder page: one row per line, with the boxes that competency uses
 * (up to six: Self, two observations, three assessor boxes). Column names come from the paper form.
 * Grey = not on the form for that line. Green = ticked. `canClick` decides which boxes are buttons.
 */
export function TickGrid({ lines, has, canClick, onClick, hint, labels, ini }: {
  labels?: Record<string, string> | null;
  lines: any[]; has: (line: any, type: string) => boolean; canClick: (line: any, type: string) => boolean;
  onClick: (line: any, type: string, on: boolean) => void; hint?: (line: any, type: string) => string;
  /** Initials to show inside a ticked box, as they are written on the paper form. */
  ini?: (line: any, type: string) => string;
}) {
  const mark = (l: any, t: string) => { const s = ini?.(l, t) || ''; return s ? s.slice(0, 3) : '✓'; };
  let sec = '', el = '';
  const TYPES = TICKS.filter((t) => lines.some((l) => l['needs_' + t])).map((t) => [t, 'needs_' + t, tickName(t, labels)] as [string, string, string]);
  return (
    <div>
      {lines.map((l) => {
        const newSec = l.section !== sec, newEl = l.element !== el || newSec; sec = l.section; el = l.element;
        return (
          <div key={l.id}>
            {newSec && <div className="sec">{l.section}</div>}
            {newEl && <><div className="el">{l.element}</div><div className="tkhead">{TYPES.map((t) => <span key={t[0]} title={t[2]}>{t[2]}</span>)}</div></>}
            <div className="ln">
              <span className="tx">{l.content}{l.auto_from_amp && <> <Pill>auto</Pill></>}</span>
              <span className="ticks">
                {TYPES.map(([type, need]) => {
                  if (!l[need]) return <span key={type} className="tk na" title="Not on the form for this line" />;
                  const on = has(l, type);
                  return canClick(l, type)
                    ? <button type="button" key={type} className={'tk' + (on ? ' on' : '')} title={hint?.(l, type)} aria-label={tickName(type, labels) + (on ? ' ticked' : ' not ticked')} onClick={() => onClick(l, type, on)}>{on ? mark(l, type) : ''}</button>
                    : <span key={type} className={'tk ro' + (on ? ' on' : '')} title={hint?.(l, type) || (l.auto_from_amp ? 'Ticks itself when the AMP is acknowledged' : 'Ticked by a manager')}>{on ? mark(l, type) : ''}</span>;
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
                const k = w.id + '|' + a.id, amp = checks.amp[k], rd = checks.ready?.[k];
                return <td key={a.id} title={rd ? (rd.ready ? 'Has everything this activity asks for' : 'Still needs — ' + rd.missing) : undefined}>
                  <StatusPill status={checks.comp[k]} />
                  <small className={amp ? 'okc' : 'noc'}>{amp === undefined ? 'No AMP yet' : amp ? '✓ AMP signed' : '✗ AMP not signed'}</small>
                  {rd && <small className={rd.ready ? 'okc' : 'noc'}>{rd.ready ? '✓ Ready' : '✗ ' + (rd.missing || '').split(' · ').length + ' missing'}</small>}</td>;
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

'use client';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { Pill } from '@/components/ui';

/** Every manual sign-off, removed tick, AMP version and login change. Cannot be edited. */
export default function ChangeLog() {
  const [kind, setKind] = useState('All'); const [rows, setRows] = useState<any[]>([]);
  useEffect(() => {
    let q = supabase.from('change_log').select('*').order('changed_at', { ascending: false }).limit(500);
    if (kind !== 'All') q = q.eq('kind', kind);
    q.then(({ data }) => setRows(data || []));
  }, [kind]);
  return (
    <div className="mpanel">
      <div className="filters">
        <div className="seg">{['All', 'Sign-off', 'AMP', 'Instructor'].map((k) => <button key={k} className={kind === k ? 'on' : ''} onClick={() => setKind(k)}>{k === 'All' ? 'All' : k + 's'}</button>)}</div>
        <div className="muted" style={{ alignSelf: 'center', fontSize: 13.5 }}>Intention changes and discussions live on the day sheet, under DM judgements and discussions.</div>
      </div>
      <div className="scroll"><table className="m">
        <thead><tr><th>When</th><th>Who</th><th>About</th><th>What</th><th>Reason</th></tr></thead>
        <tbody>{rows.length ? rows.map((l) => (
          <tr key={l.id}><td style={{ whiteSpace: 'nowrap' }}>{new Date(l.changed_at).toLocaleString('en-NZ', { timeZone: 'Pacific/Auckland', day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })}</td>
            <td>{l.changed_by}</td><td><Pill>{l.kind}</Pill></td><td>{l.what}</td><td>{l.reason}</td></tr>
        )) : <tr><td colSpan={5} className="muted">Nothing logged yet.</td></tr>}</tbody>
      </table></div>
    </div>
  );
}

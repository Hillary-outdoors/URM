'use client';
import { useState } from 'react';
import { supabase } from '@/lib/supabase';
import { fd, nzToday } from '@/lib/util';
import { Pill, Sheet } from '@/components/ui';

const dmName = () => { try { return localStorage.getItem('dmName') || ''; } catch (e) { return ''; } };
async function api(method: string, body: any) {
  const { data } = await supabase.auth.getSession();
  const res = await fetch('/api/instructors', { method, headers: { 'content-type': 'application/json', authorization: 'Bearer ' + (data.session?.access_token || '') }, body: JSON.stringify(body) });
  const json = await res.json().catch(() => ({}));
  return res.ok ? { ok: true, ...json } : { ok: false, error: json.error || 'Something went wrong.' };
}
const log = (what: string) => supabase.from('change_log').insert({ kind: 'Instructor', what, changed_by: 'Manager · ' + (dmName() || 'unnamed') });

/** Add instructors (this creates their login), edit their details, reset passwords. */
export default function People({ base, reload }: any) {
  const [f, setF] = useState<any>(null); const [err, setErr] = useState(''); const [busy, setBusy] = useState(false); const [show, setShow] = useState('current');
  const set = (k: string, v: any) => setF({ ...f, [k]: v });
  const list = base.instructors.filter((p: any) => p.account_type === 'instructor' && (show === 'all' || p.employment !== 'Past staff'));
  const blank = { isNew: true, name: '', initials: '', email: '', password: '', centre_id: base.centres[0]?.id || '', employment: 'Staff', start_date: nzToday() };

  async function save() {
    setErr('');
    if (!f.name.trim()) return setErr('A name is needed.');
    setBusy(true);
    if (f.isNew) {
      const r = await api('POST', f); setBusy(false);
      if (!r.ok) return setErr(r.error);
      await log(`Added ${f.name.trim()} (${f.employment}) and created their login`);
    } else {
      const was = base.instructors.find((p: any) => p.id === f.id);
      const { error } = await supabase.from('instructors').update({
        name: f.name.trim(), initials: f.initials || null, centre_id: f.centre_id || null, employment: f.employment, start_date: f.start_date || null,
        end_date: f.employment === 'Past staff' ? f.end_date || nzToday() : null,
      }).eq('id', f.id);
      if (error) { setBusy(false); return setErr(error.message); }
      if (was.employment !== f.employment) {
        // Past staff keep every record but can no longer log in.
        const r = await api('PATCH', { instructor_id: f.id, disabled: f.employment === 'Past staff' });
        if (!r.ok && was.auth_user_id) { setBusy(false); return setErr('Details saved, but the login could not be switched: ' + r.error); }
        await log(`${f.name.trim()}: ${was.employment} → ${f.employment}`);
      }
      if (f.password) {
        const r = await api('PATCH', { instructor_id: f.id, password: f.password });
        if (!r.ok) { setBusy(false); return setErr(r.error); }
        await log(`Reset password for ${f.name.trim()}`);
      }
      setBusy(false);
    }
    setF(null); reload();
  }

  return (
    <div className="mpanel">
      <div className="filters">
        <button className="btn primary" onClick={() => { setErr(''); setF(blank); }}>+ Add instructor</button>
        <div className="seg"><button className={show === 'current' ? 'on' : ''} onClick={() => setShow('current')}>Current</button><button className={show === 'all' ? 'on' : ''} onClick={() => setShow('all')}>Include past staff</button></div>
      </div>
      <div className="scroll"><table className="m">
        <thead><tr><th>Name</th><th>Type</th><th>Centre</th><th>Start date</th><th>Login</th><th></th></tr></thead>
        <tbody>{list.length ? list.map((p: any) => (
          <tr key={p.id}><td><b>{p.name}</b>{p.initials ? ' (' + p.initials + ')' : ''}</td>
            <td><Pill kind={p.employment === 'Staff' ? 'good' : p.employment === 'Contractor' ? 'info' : 'mute'}>{p.employment}</Pill></td>
            <td>{base.centres.find((c: any) => c.id === p.centre_id)?.name || ''}</td><td>{fd(p.start_date)}</td>
            <td>{p.auth_user_id ? (p.employment === 'Past staff' ? 'Switched off' : 'Active') : 'None'}</td>
            <td><button className="btn small" onClick={() => { setErr(''); setF({ ...p, initials: p.initials || '', centre_id: p.centre_id || '', start_date: p.start_date || '', password: '' }); }}>Edit</button></td></tr>
        )) : <tr><td colSpan={6} className="muted">No instructors yet. Add the first one.</td></tr>}</tbody>
      </table></div>
      <p className="muted" style={{ fontSize: 13 }}>There are two kinds of login: instructor and manager. Instructors are added here. The manager login is looked after in the Supabase dashboard.</p>
      <Sheet open={!!f} onClose={() => setF(null)}>
        {f && <>
          <button className="back" onClick={() => setF(null)}>‹ Back</button>
          <h3>{f.isNew ? 'Add instructor' : 'Edit ' + f.name}</h3>
          <label className="f" htmlFor="pn">Full name</label><input id="pn" type="text" value={f.name} onChange={(e) => set('name', e.target.value)} />
          <label className="f" htmlFor="pi">Initials</label><input id="pi" type="text" value={f.initials} onChange={(e) => set('initials', e.target.value)} />
          <div className="grid2">
            <div><label className="f" htmlFor="pc">Centre</label><select id="pc" value={f.centre_id} onChange={(e) => set('centre_id', e.target.value ? +e.target.value : '')}><option value="">None</option>{base.centres.map((c: any) => <option key={c.id} value={c.id}>{c.name}</option>)}</select></div>
            <div><label className="f" htmlFor="pe">Type</label><select id="pe" value={f.employment} onChange={(e) => set('employment', e.target.value)}><option>Staff</option><option>Contractor</option><option>Past staff</option></select></div>
          </div>
          <label className="f" htmlFor="ps">Start date</label><input id="ps" type="date" value={f.start_date} onChange={(e) => set('start_date', e.target.value)} />
          {f.isNew ? <>
            <label className="f" htmlFor="pm">Email (their login)</label><input id="pm" type="email" value={f.email} onChange={(e) => set('email', e.target.value)} />
            <label className="f" htmlFor="pw">Starting password (10 characters or more)</label><input id="pw" type="text" value={f.password} onChange={(e) => set('password', e.target.value)} />
            <small className="muted">Give them this password in person. They can change it under Account once they sign in. A new instructor starts with every competency at Not started and every AMP waiting to be signed.</small>
          </> : <>
            <label className="f" htmlFor="pw">Reset password (leave blank to keep it)</label><input id="pw" type="text" value={f.password} onChange={(e) => set('password', e.target.value)} placeholder="10 characters or more" />
            {f.employment === 'Past staff' && <small className="muted">Past staff keep all their records but their login is switched off and they drop out of the search lists.</small>}
          </>}
          <div className="msg bad">{err}</div>
          <button className="btn primary" disabled={busy} onClick={save}>{busy ? 'Saving…' : 'Save'}</button>
        </>}
      </Sheet>
    </div>
  );
}

'use client';
import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

/**
 * The maps and photos on an AMP. The same component on both sides: `canEdit` turns the uploading
 * and removing on for a manager, and leaves the instructor's AMP read-only.
 *
 * The bucket is private on purpose — an AMP names access arrangements and emergency response for
 * real places — so each file is shown through a short-lived signed link rather than a public URL.
 */

const KINDS = ['Map', 'Photo', 'Diagram', 'Other'];
const BUCKET = 'amp-media';
const MAX = 10 * 1024 * 1024;

const isImage = (p: string) => /\.(png|jpe?g|webp|gif)$/i.test(p);
/** A file name safe to put in a path, without losing what it was called. */
const tidy = (n: string) => n.toLowerCase().replace(/[^a-z0-9.]+/g, '-').replace(/^-+|-+$/g, '').slice(-60);

export default function AmpMedia({ ampId, canEdit, addedBy }: { ampId: number; canEdit?: boolean; addedBy?: string }) {
  const [rows, setRows] = useState<any[]>([]);
  const [urls, setUrls] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState('');
  const [kind, setKind] = useState('Map');
  const [caption, setCaption] = useState('');

  const load = useCallback(async () => {
    if (!ampId) { setRows([]); setUrls({}); return; }
    const { data, error } = await supabase.from('amp_media').select('*')
      .eq('amp_id', ampId).order('sort_order').order('id');
    if (error) { setErr(error.message); return; }
    setRows(data || []);
    const paths = (data || []).map((r: any) => r.path);
    if (paths.length) {
      // One signed link per file, good for an hour. Long enough to read an AMP on the hill.
      const { data: signed } = await supabase.storage.from(BUCKET).createSignedUrls(paths, 3600);
      const m: Record<string, string> = {};
      (signed || []).forEach((s: any) => { if (s.signedUrl && s.path) m[s.path] = s.signedUrl; });
      setUrls(m);
    } else setUrls({});
  }, [ampId]);
  useEffect(() => { load(); }, [load]);

  async function add(file: File) {
    setErr('');
    if (file.size > MAX) return setErr('That file is ' + Math.round(file.size / 1048576) + 'MB. Keep it under 10MB — a photo from a phone usually needs resizing first.');
    setBusy(true);
    const path = `${ampId}/${Date.now()}-${tidy(file.name)}`;
    const up = await supabase.storage.from(BUCKET).upload(path, file, { contentType: file.type || undefined });
    if (up.error) { setBusy(false); return setErr(up.error.message); }
    const { error } = await supabase.from('amp_media').insert({
      amp_id: ampId, path, kind, caption: caption.trim() || null,
      sort_order: rows.length + 1, added_by: addedBy || null,
    });
    setBusy(false);
    if (error) {
      // Do not leave the file sitting in the bucket with nothing pointing at it.
      await supabase.storage.from(BUCKET).remove([path]);
      return setErr(error.message);
    }
    setCaption(''); load();
  }

  async function remove(r: any) {
    if (!window.confirm('Remove this ' + r.kind.toLowerCase() + ' from the AMP?')) return;
    setBusy(true);
    const { error } = await supabase.from('amp_media').delete().eq('id', r.id);
    if (!error) await supabase.storage.from(BUCKET).remove([r.path]);
    setBusy(false);
    if (error) return setErr(error.message);
    load();
  }

  async function recaption(r: any, text: string) {
    setRows((p) => p.map((x) => (x.id === r.id ? { ...x, caption: text } : x)));
    const { error } = await supabase.from('amp_media').update({ caption: text.trim() || null }).eq('id', r.id);
    if (error) setErr(error.message);
  }

  if (!canEdit && !rows.length) return null;

  return (
    <div className={canEdit ? '' : 'card'} style={{ marginTop: canEdit ? 14 : 0 }}>
      <h3 style={{ fontSize: canEdit ? 16 : 15, marginBottom: 4 }}>
        Maps and photos{rows.length ? ' (' + rows.length + ')' : ''}
      </h3>
      {err && <div className="msg bad">{err}</div>}

      {rows.length === 0
        ? <p className="muted" style={{ fontSize: 13.5, margin: 0 }}>
            {canEdit ? 'Nothing attached yet. A site map or a photo of the anchor goes a long way on the hill.' : 'None attached.'}
          </p>
        : <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(240px,1fr))', gap: 12, marginTop: 8 }}>
            {rows.map((r) => (
              <div key={r.id} className="card" style={{ margin: 0 }}>
                <div className="rowflex" style={{ justifyContent: 'space-between', alignItems: 'baseline' }}>
                  <small className="muted">{r.kind}</small>
                  {canEdit && <button className="btn small" disabled={busy} aria-label="Remove" onClick={() => remove(r)}>×</button>}
                </div>
                {urls[r.path]
                  ? isImage(r.path)
                    ? <a href={urls[r.path]} target="_blank" rel="noreferrer">
                        {/* eslint-disable-next-line @next/next/no-img-element */}
                        <img src={urls[r.path]} alt={r.caption || r.kind + ' for this AMP'}
                          style={{ width: '100%', height: 'auto', borderRadius: 8, display: 'block', marginTop: 6 }} />
                      </a>
                    : <a className="btn small" style={{ marginTop: 6, display: 'inline-block' }}
                        href={urls[r.path]} target="_blank" rel="noreferrer">Open the file</a>
                  : <div className="muted" style={{ fontSize: 13, marginTop: 6 }}>Could not load this one.</div>}
                {canEdit
                  ? <input type="text" aria-label="Caption" placeholder="Caption" defaultValue={r.caption || ''}
                      style={{ marginTop: 6 }} onBlur={(e) => e.target.value !== (r.caption || '') && recaption(r, e.target.value)} />
                  : r.caption ? <div style={{ fontSize: 13.5, marginTop: 6 }}>{r.caption}</div> : null}
              </div>
            ))}
          </div>}

      {canEdit && (
        <div className="filters" style={{ marginTop: 12 }}>
          <div style={{ maxWidth: 140 }}><label className="f" style={{ marginTop: 0 }} htmlFor="am-kind">What is it</label>
            <select id="am-kind" value={kind} onChange={(e) => setKind(e.target.value)}>
              {KINDS.map((k) => <option key={k}>{k}</option>)}
            </select></div>
          <div style={{ flex: 1, minWidth: 180 }}><label className="f" style={{ marginTop: 0 }} htmlFor="am-cap">Caption (optional)</label>
            <input id="am-cap" type="text" value={caption} onChange={(e) => setCaption(e.target.value)} placeholder="Access track and the top anchor" /></div>
          <div><label className="f" style={{ marginTop: 0 }} htmlFor="am-file">File</label>
            <input id="am-file" type="file" accept="image/png,image/jpeg,image/webp,image/gif,application/pdf"
              disabled={busy} onChange={(e) => { const f = e.target.files?.[0]; if (f) add(f); e.target.value = ''; }} /></div>
          {busy && <span className="muted" style={{ alignSelf: 'center' }}>Uploading…</span>}
        </div>
      )}
      {canEdit && <p className="muted" style={{ fontSize: 12.5, margin: '6px 0 0' }}>
        PNG, JPEG, WebP, GIF or PDF, up to 10MB. Instructors see these on the AMP on their phone.
        The files are not public — the app hands out a link that expires.
      </p>}
    </div>
  );
}

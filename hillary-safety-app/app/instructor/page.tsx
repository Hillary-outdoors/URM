'use client';
import { useCallback, useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase, getMe } from '@/lib/supabase';
import { PLAN_QUICK, AIM_QUICK, INT_SELECT, shapeInt, needsCall, nzToday, fd, hm, downloadCsv, intentionRows, STATUS } from '@/lib/util';
import { Pill, StatusPill, Picker, Quick, TickGrid } from '@/components/ui';
import TrainingLogForm from '@/components/TrainingLogForm';
import { Mark } from '@/components/Logo';
import DayBoard from '@/components/DayBoard';
import AmpMedia from '@/components/AmpMedia';

const AMP_FIELDS: [string, string][] = [
  ['activity_description', 'Activity description'], ['location', 'Location'], ['emergency_response', 'Emergency response'],
  ['instructor_requirements', 'Instructor requirements'], ['client_competencies', 'Client competencies'],
  ['specific_equipment', 'Specific equipment'], ['specific_policies', 'Specific policies'], ['access_permission', 'Access permission'],
  ['camping', 'Camping'], ['toilets', 'Toilets'], ['water', 'Water'], ['key_hazards', 'Key hazards'], ['other_resources', 'Other resources and notes'],
];

/** The instructor side: a phone-first app with five tabs. */
export default function InstructorApp() {
  const router = useRouter();
  const [me, setMe] = useState<any>(null);
  const [tab, setTab] = useState('home');
  const [d, setD] = useState<any>({ activities: [], instructors: [], amps: [], comps: [], ints: [], centres: [] });
  const [err, setErr] = useState('');

  const load = useCallback(async (m: any) => {
    const [act, ins, amp, comp, ints, cen, all] = await Promise.all([
      supabase.from('activities').select('*').eq('active', true).order('name'),
      supabase.from('instructors').select('id,name,initials,centre_id,employment,account_type').eq('account_type', 'instructor').neq('employment', 'Past staff').order('name'),
      supabase.from('v_amp_status').select('*').eq('instructor_id', m.id).gt('version', 0).order('title'),
      supabase.from('v_competency_status').select('*').eq('instructor_id', m.id).order('level').order('name'),
      supabase.from('intentions').select(INT_SELECT).order('date', { ascending: false }).limit(500),
      supabase.from('centres').select('*').order('id'),
      supabase.from('competencies').select('id,name,level,centre_id').order('level').order('name'),
    ]);
    const bad = [act, ins, amp, comp, ints, cen, all].find((r) => r.error);
    if (bad) setErr(bad.error!.message);
    setD({
      activities: act.data || [], instructors: ins.data || [], amps: amp.data || [],
      meId: m.id,
      comps: (comp.data || []).filter((c: any) => !c.centre_id || !m.centre_id || c.centre_id === m.centre_id),
      ints: (ints.data || []).map(shapeInt),
      centres: cen.data || [],
      allComps: (all.data || []).filter((c: any) => !c.centre_id || !m.centre_id || c.centre_id === m.centre_id),
    });
  }, []);

  useEffect(() => {
    getMe().then((r) => {
      if (!r) return router.replace('/login');
      if (!r.me) { setErr('Your login is not linked to an instructor record yet. Ask a manager.'); return; }
      if (r.me.account_type === 'manager') return router.replace('/manager');
      setMe(r.me); load(r.me);
    });
  }, [router, load]);

  if (!me) return <div className="login"><p className="muted">{err || 'Loading…'}</p>{err && <button className="btn" onClick={async () => { await supabase.auth.signOut(); router.replace('/login'); }}>Sign out</button>}</div>;
  const reload = () => load(me);
  const open = d.ints.filter((i: any) => i.status !== 'Closed');
  const todoAmps = d.amps.filter((a: any) => !a.up_to_date);

  return (
    <>
      <div className="appbar">
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}><Mark size={26} /><div><small>Instructor</small><h1>{me.name}</h1></div></div>
        <div className="sp"><button className="btn small" onClick={() => setTab('account')}>Account</button></div>
      </div>
      <div className="narrow">
        {err && <div className="inc">{err}</div>}
        {tab === 'home' && <Home d={d} open={open} todoAmps={todoAmps} go={setTab} />}
        {tab === 'intent' && <Intent me={me} d={d} open={open} reload={reload} />}
        {tab === 'day' && <DayBoard me={me} centres={d.centres} />}
        {tab === 'progress' && <Progress me={me} d={d} reload={reload} />}
        {tab === 'tlog' && <TrainingLog me={me} d={d} reload={reload} />}
        {tab === 'amps' && <Amps d={d} reload={reload} />}
        {tab === 'logbook' && <Logbook me={me} d={d} />}
        {tab === 'account' && <Account />}
      </div>
      <nav className="inav">
        {[['home', 'Home'], ['intent', 'Intention'], ['day', 'Day'], ['progress', 'Competencies'], ['tlog', 'Training log'], ['amps', 'AMPs'], ['logbook', 'Logbook']].map(([k, l]) => (
          <button key={k} className={tab === k ? 'on' : ''} onClick={() => setTab(k)}>{l}</button>
        ))}
      </nav>
    </>
  );
}

const names = (ids: any[], list: any[]) => ids.map((id) => list.find((x) => x.id === id)?.name || '?');

function IntLine({ i, d }: any) {
  const call = needsCall(i, d.activities);
  return (
    <>
      <b>{names(i.acts, d.activities).join(' + ')}</b>
      <div>{fd(i.date)}{i.pax ? ` · ${i.pax} pax` : ''}{i.who.length > 1 ? ' · with ' + names(i.who.filter((w: string) => w !== d.meId), d.instructors).join(', ') : ''}</div>
      {call && <small className="muted">{i.started_at ? 'Started ' + hm(i.started_at) : 'Not started yet'}{i.due_by ? ' · due ' + hm(i.due_by) : ''}</small>}
    </>
  );
}

/**
 * The home screen is what you are doing today, and little else. The AMP list used to sit here a
 * row at a time and ran off the bottom of the phone, so it is one line now and the AMPs tab has
 * the detail.
 */
function Home({ d, open, todoAmps, go }: any) {
  const l1 = d.comps.filter((c: any) => c.level === 1), done = l1.filter((c: any) => c.status === 'Competent').length;
  const next = d.comps.filter((c: any) => c.status !== 'Competent').slice(0, 3);
  return (
    <>
      <div className="card">
        <h3>Today</h3>
        {open.length ? open.map((i: any) => (
          <div key={i.id} style={{ marginBottom: 10 }}>
            <div className="check">
              <span className={'dot ' + (i.status === 'Approved' ? 'ok' : 'wait')}>{i.status === 'Approved' ? '✓' : '…'}</span>
              <span style={{ flex: 1 }}>
                <IntLine i={i} d={d} />
                {i.outcome_of_day && <div style={{ fontSize: 13.5 }}>{i.outcome_of_day}</div>}
                {i.plan && <div><small className="muted">Plan: {i.plan}</small></div>}
                {i.weather_note && <div><small className="muted">Weather: {i.weather_note}</small></div>}
                <div><small className="muted">
                  {i.status === 'Approved' ? 'Approved by the DM' : 'Sent. Waiting for the DM'}
                  {i.dm_notes ? ' · DM note: ' + i.dm_notes : ''}
                </small></div>
              </span>
            </div>
          </div>
        )) : <>
          <p className="muted" style={{ margin: '0 0 8px' }}>Nothing out at the moment.</p>
          <button className="btn primary" style={{ width: '100%' }} onClick={() => go('intent')}>Submit an intention</button>
        </>}
        {!!open.length && <p className="muted" style={{ fontSize: 12.5, margin: 0 }}>
          The DM takes the calls and closes the trip from the laptop. Call in by radio or phone as usual.
        </p>}
      </div>
      {todoAmps.length > 0 && (
        <div className="card todo">
          <h3>To do</h3>
          <button className="rowbtn" onClick={() => go('amps')}>
            <span><span className="t">{todoAmps.length === 1
              ? 'Read and sign 1 AMP'
              : 'Read and sign ' + todoAmps.length + ' AMPs'}</span>
              <small>{todoAmps.slice(0, 2).map((a: any) => a.title).join(', ')}{todoAmps.length > 2 ? ' and ' + (todoAmps.length - 2) + ' more' : ''}</small>
            </span><Pill kind="warn">{todoAmps.length}</Pill>
          </button>
        </div>
      )}
      <div className="card">
        <h3>Level 1 progress</h3>
        <div>{done} of {l1.length} competencies Competent</div>
        <div className={'bar' + (l1.length && done === l1.length ? ' done' : '')} ><i style={{ width: (l1.length ? (done / l1.length) * 100 : 0) + '%' }} /></div>
        {!!next.length && <div className="sec">Working on</div>}
        {next.map((c: any) => <div className="check" key={c.comp_id}><span className="dot wait">→</span><span>{c.name} (L{c.level}) · {c.done} of {c.total} ticks</span></div>)}
        <button className="btn small" style={{ marginTop: 6 }} onClick={() => go('progress')}>See all progress</button>
      </div>
      <div className="card">
        <h3>The rest of the day</h3>
        <p className="muted" style={{ margin: '0 0 8px' }}>See who else is out, what they are doing and when they are due back.</p>
        <button className="btn" onClick={() => go('day')}>Open the day board</button>
      </div>
    </>
  );
}

function Intent({ me, d, open, reload }: any) {
  const [acts, setActs] = useState<number[]>([]); const [buddy, setBuddy] = useState<string[]>([]);
  const [ov, setOv] = useState(false); const [due, setDue] = useState('15:00'); const [pax, setPax] = useState('12');
  const [aim, setAim] = useState(''); const [plan, setPlan] = useState(''); const [msg, setMsg] = useState<[string, string]>(['', '']);
  const [wx, setWx] = useState(''); const [busy, setBusy] = useState(false);
  const act = (id: number) => d.activities.find((a: any) => a.id === id);
  // Every trip gets a time to be back by. It is the only thing the overdue watch has to go on,
  // so there is no such thing as a trip that does not need one.
  const compFor = (a: number) => d.comps.filter((c: any) => c.act_id === a).sort((x: any, y: any) => x.level - y.level)[0];
  const ampFor = (a: number) => d.amps.find((x: any) => x.act_id === a);

  async function send() {
    if (!acts.length) return setMsg(['bad', 'Pick at least one activity.']);
    if (!due) return setMsg(['bad', 'Put in a time to be back by. Without one nobody is watching the clock for you.']);
    if (!me.centre_id) return setMsg(['bad', 'Your record has no centre set. Ask a manager to add it.']);
    setBusy(true);
    const { error } = await supabase.rpc('submit_intention', {
      p_centre: me.centre_id, p_date: nzToday(), p_acts: acts, p_with: buddy, p_overnight: ov,
      p_due: due || null, p_pax: pax ? +pax : null, p_outcome: aim, p_plan: plan,
      p_weather: wx.trim() || null,
    });
    setBusy(false);
    if (error) return setMsg(['bad', error.message]);
    setActs([]); setBuddy([]); setOv(false); setAim(''); setPlan(''); setWx('');
    setMsg(['ok', 'Sent to the Duty Manager.']); reload();
  }

  return (
    <>
      {/* What you are out on, to look at. Calls are taken by the DM on the laptop. */}
      {open.map((i: any) => (
        <div className="card" key={i.id}>
          <h3>Out at the moment</h3>
          <IntLine i={i} d={d} />
          {i.outcome_of_day && <div style={{ fontSize: 13.5, marginTop: 4 }}>{i.outcome_of_day}</div>}
          {i.plan && <div><small className="muted">Plan: {i.plan}</small></div>}
          {i.weather_note && <div><small className="muted">Weather: {i.weather_note}</small></div>}
          <div><small className="muted">
            {i.status === 'Approved' ? 'Approved by the DM' : 'Sent. Waiting for the DM'}
            {i.dm_notes ? ' · DM note: ' + i.dm_notes : ''}
          </small></div>
          <p className="muted" style={{ fontSize: 12.5, margin: '8px 0 0' }}>
            Call in by radio or phone as usual. The DM logs it and closes the trip from the laptop.
          </p>
        </div>
      ))}
      <div className="card">
        <h3>New intention</h3>
        <label className="f">Activities</label>
        <Picker options={d.activities.map((a: any) => ({ id: a.id, label: a.name }))} value={acts} onChange={setActs} placeholder="Search activities…" />
        {acts.map((a) => {
          const c = compFor(a), k = ampFor(a);
          return (
            <div key={a} style={{ marginTop: 8, borderTop: '1px solid var(--line)', paddingTop: 6 }}>
              <b>{act(a)?.name}</b>
              <div className="check"><span className={'dot ' + (c?.status === 'Competent' ? 'ok' : 'no')}>{c?.status === 'Competent' ? '✓' : '!'}</span>
                <span><StatusPill status={c?.status} />{c && c.status !== 'Competent' ? ' You need a Competent instructor with you, or DM approval.' : ''}</span></div>
              <div className="check"><span className={'dot ' + (k?.up_to_date ? 'ok' : 'no')}>{k?.up_to_date ? '✓' : '!'}</span>
                <span>{!k ? 'No AMP published for this activity yet.' : k.up_to_date ? `AMP signed, version ${k.version}` : 'AMP not signed. Open the AMPs tab to read and sign it.'}</span></div>
            </div>
          );
        })}
        <label className="f">Working with</label>
        <Picker options={d.instructors.filter((p: any) => p.id !== me.id).map((p: any) => ({ id: p.id, label: p.name }))} value={buddy} onChange={setBuddy} placeholder="Search for an instructor…" />
        <div className="check"><input type="checkbox" id="iov" checked={ov} onChange={(e) => setOv(e.target.checked)} style={{ width: 18, height: 18 }} /><label htmlFor="iov">Overnight trip</label></div>
        <label className="f" htmlFor="idue">Due back by</label>
        <input id="idue" type="time" value={due} onChange={(e) => setDue(e.target.value)} required />
        <small className="muted">Every trip needs one. If you are not back by then the DM's screen turns yellow after
          10 minutes and red after 20, until someone calls in.</small>
        <label className="f" htmlFor="ipax">Participants</label><input id="ipax" type="number" min={1} value={pax} onChange={(e) => setPax(e.target.value)} />
        <label className="f" htmlFor="iaim">Outcome of the day</label><input id="iaim" type="text" value={aim} onChange={(e) => setAim(e.target.value)} placeholder="What the group is working towards" />
        <Quick items={AIM_QUICK} onPick={(t) => setAim(aim.trim() ? aim.trim() + ', ' + t : t)} />
        <label className="f" htmlFor="iplan">Plan or route</label><textarea id="iplan" rows={2} value={plan} onChange={(e) => setPlan(e.target.value)} placeholder="Where you are going, in order" />
        <Quick items={PLAN_QUICK} onPick={(t) => setPlan(plan.trim() ? plan.trim() + ' – ' + t : t)} />
        <label className="f" htmlFor="iwx">A comment on the weather (optional)</label>
        <input id="iwx" type="text" value={wx} onChange={(e) => setWx(e.target.value)} placeholder="What you are seeing out there" />
        <small className="muted">Goes to the DM alongside their own forecast.</small>
        <div className={'msg ' + msg[0]}>{msg[1]}</div>
        <button className="btn primary" style={{ width: '100%' }} disabled={busy} onClick={send}>Send to Duty Manager</button>
      </div>
    </>
  );
}

/** The wording a log's author is allowed to tidy up afterwards. */
const LOG_EDIT: [string, string, boolean][] = [
  ['activity_text', 'Activity or pursuit', false], ['location', 'Location', false],
  ['outcome_comments', 'Comments on the outcome', false],
  ['summary', 'Summary of the session', true], ['how_it_went', 'How the session went', true],
  ['weather_conditions', 'Weather and environmental conditions', true],
  ['self_observation', 'The instructor’s own reflection', true],
  ['dev_needs', 'Developmental needs identified', true],
  ['feedback_given', 'Feedback given and next steps', true],
];
/** Kept from the Smartsheet years. Shown when a log has them, never asked for again. */
const LOG_OLD: [string, string][] = [
  ['session_objectives', 'Session objectives'], ['sms_ok', 'Followed the SMS'],
  ['sms_comments', 'Comments on hazards and the SMS'], ['next_steps', 'Recommended next steps'],
  ['client_group', 'Client group present'], ['training_context', 'Clients present'],
  ['folder_updated', 'Folder updated'],
];

/** Record a training session, and open any session you are named on. */
function TrainingLog({ me, d, reload }: any) {
  const [mine, setMine] = useState<any[]>([]);
  const [sel, setSel] = useState<any>(null);
  const [edit, setEdit] = useState<any>(null);
  const [done, setDone] = useState(''); const [msg, setMsg] = useState<[string, string]>(['', '']);

  const load = useCallback(async () => {
    // Every session that names you: about you, written by you, or run by you.
    const { data } = await supabase.from('training_logs')
      .select('*, training_log_comps(comp_id)')
      .or(`instructor_id.eq.${me.id},filled_by.eq.${me.id},trainer_id.eq.${me.id}`)
      .order('date', { ascending: false }).limit(100);
    setMine(data || []);
  }, [me.id]);
  useEffect(() => { load(); }, [load]);

  const compName = (id: number) => { const c = (d.allComps || []).find((x: any) => x.id === id); return c ? c.name + ' L' + c.level : ''; };
  const role = (l: any) => l.instructor_id === me.id ? 'About you'
    : l.filled_by === me.id ? 'Written by you' : 'You ran it';

  async function saveEdit() {
    setMsg(['', '']);
    const patch: any = {};
    LOG_EDIT.forEach(([k]) => { patch[k] = (edit[k] || '').trim() || null; });
    ['clients_present', 'students_aware', 'linked_to_frame'].forEach((k) => { patch[k] = edit[k] || null; });
    const { error } = await supabase.from('training_logs').update(patch).eq('id', sel.id);
    if (error) return setMsg(['bad', error.message]);
    setMsg(['ok', 'Saved.']); setSel({ ...sel, ...patch }); setEdit(null); load();
  }

  if (sel) {
    const canEdit = sel.filled_by === me.id;
    return (
      <>
        <button className="back" onClick={() => { setSel(null); setEdit(null); setMsg(['', '']); }}>‹ All sessions</button>
        <div className="card">
          <div className="rowflex" style={{ justifyContent: 'space-between', alignItems: 'baseline' }}>
            <h3 style={{ margin: 0 }}>{fd(sel.date)} · {sel.activity_text || 'Training'}</h3>
            {sel.outcome ? <Pill kind={STATUS[sel.outcome] || 'mute'}>{sel.outcome}</Pill> : null}
          </div>
          <div className="muted" style={{ fontSize: 13 }}>
            {role(sel)} · trainer {sel.trainer || 'not named'}
            {sel.days ? ' · ' + sel.days + ' day' + (Number(sel.days) === 1 ? '' : 's') : ''}
            {sel.ticks_made ? ' · ' + sel.ticks_made + ' boxes ticked' : ''}
          </div>
          {(sel.training_log_comps || []).length > 0 && <div style={{ marginTop: 6 }}>
            {(sel.training_log_comps || []).map((x: any) => <span key={x.comp_id} style={{ marginRight: 6 }}><Pill>{compName(x.comp_id)}</Pill></span>)}
          </div>}
        </div>

        {!edit && (
          <div className="card">
            <dl>
              {[['training_type', 'Training type'], ['session_type', 'Type of session'], ['location', 'Location'],
                ['outcome_comments', 'Comments on the outcome'], ['summary', 'Summary of the session'],
                ['how_it_went', 'How the session went'], ['weather_conditions', 'Weather and environmental conditions'],
                ['clients_present', 'Clients present'], ['students_aware', 'Students knew the objective'],
                ['linked_to_frame', 'Linked to the daily frame'],
                ['self_observation', 'The instructor’s own reflection'],
                ['dev_needs', 'Developmental needs identified'],
                ['feedback_given', 'Feedback given and next steps'],
                ...LOG_OLD]
                .filter(([k]) => sel[k])
                .map(([k, l]) => <span key={k} style={{ display: 'contents' }}><dt>{l}</dt><dd>{sel[k]}</dd></span>)}
            </dl>
            <div className={'msg ' + msg[0]}>{msg[1]}</div>
            {canEdit
              ? <><button className="btn" onClick={() => setEdit({ ...sel })}>Edit the wording</button>
                  <p className="muted" style={{ fontSize: 12.5, margin: '8px 0 0' }}>
                    You can tidy up what you wrote. To change the outcome or the boxes it ticked, ask a
                    manager to undo the entry — that puts the ticks back and you can write it again.
                  </p></>
              : <p className="muted" style={{ fontSize: 12.5, margin: 0 }}>
                  Written by {sel.filled_by === sel.instructor_id ? 'the instructor themselves' : 'someone else'}, so only they or a manager can change it.
                </p>}
          </div>
        )}

        {edit && (
          <div className="card">
            <h3 style={{ fontSize: 15 }}>Edit the wording</h3>
            {LOG_EDIT.map(([k, label, big]) => (
              <span key={k} style={{ display: 'contents' }}>
                <label className="f" htmlFor={'e-' + k}>{label}</label>
                {big
                  ? <textarea id={'e-' + k} rows={3} value={edit[k] || ''} onChange={(e) => setEdit({ ...edit, [k]: e.target.value })} />
                  : <input id={'e-' + k} type="text" value={edit[k] || ''} onChange={(e) => setEdit({ ...edit, [k]: e.target.value })} />}
              </span>
            ))}
            {[['clients_present', 'Clients present during the session'], ['students_aware', 'Students knew the objective and it suited them'],
              ['linked_to_frame', 'Linked to the daily frame']].map(([k, label]) => (
              <span key={k} style={{ display: 'contents' }}>
                <label className="f" htmlFor={'e-' + k}>{label}</label>
                <select id={'e-' + k} value={edit[k] || ''} onChange={(e) => setEdit({ ...edit, [k]: e.target.value })}>
                  <option value="">—</option><option value="Yes">Yes</option><option value="No">No</option>
                  {k === 'linked_to_frame' && <option value="Not applicable">Not applicable</option>}
                </select>
              </span>
            ))}
            <div className={'msg ' + msg[0]}>{msg[1]}</div>
            <div className="rowflex" style={{ marginTop: 10 }}>
              <button className="btn primary" onClick={saveEdit}>Save</button>
              <button className="btn" onClick={() => { setEdit(null); setMsg(['', '']); }}>Cancel</button>
            </div>
          </div>
        )}
      </>
    );
  }

  return (
    <>
      {done && <div className="hl">{done}</div>}
      <TrainingLogForm me={me} people={d.instructors || []} comps={d.allComps || []}
        onDone={(m: string) => { setDone(m); load(); reload?.(); }} />
      <h3 style={{ marginTop: 18 }}>Every session you are named on</h3>
      {mine.length === 0 ? <p className="muted">Nothing yet.</p> : mine.map((l) => (
        <button className="rowbtn" key={l.id} onClick={() => setSel(l)}>
          <span style={{ flex: 1 }}>
            <span className="t">{fd(l.date)} · {l.activity_text || 'Training'}</span>
            <small>{role(l)} · trainer {l.trainer || 'not named'}
              {(l.training_log_comps || []).length ? ' · ' + (l.training_log_comps || []).map((x: any) => compName(x.comp_id)).filter(Boolean).join(', ') : ''}</small>
          </span>
          {l.outcome ? <Pill kind={STATUS[l.outcome] || 'mute'}>{l.outcome}</Pill> : null}
        </button>
      ))}
    </>
  );
}

function Progress({ me, d, reload }: any) {
  const [comp, setComp] = useState<any>(null); const [lines, setLines] = useState<any[]>([]); const [ticks, setTicks] = useState<Set<string>>(new Set());
  const [tickInfo, setTickInfo] = useState<Map<string, any>>(new Map());
  const [ampSigned, setAmpSigned] = useState(false);
  const open = useCallback(async (c: any) => {
    setComp(c);
    const { data: ls } = await supabase.from('competency_lines').select('*').eq('comp_id', c.comp_id).order('sort_order').order('id');
    // One indexed lookup instead of a web address listing every line number on the form.
    const { data: so } = (ls || []).length
      ? await supabase.from('comp_signoffs').select('line_id,tick_type,initials,signed_by,observed_on, competency_lines!inner(comp_id)')
          .eq('instructor_id', me.id).eq('competency_lines.comp_id', c.comp_id)
      : { data: [] as any[] };
    setLines(ls || []); setTicks(new Set((so || []).map((s: any) => s.line_id + '|' + s.tick_type)));
    setTickInfo(new Map((so || []).map((s: any) => [s.line_id + '|' + s.tick_type, s])));
    setAmpSigned(!!d.amps.find((a: any) => a.act_id === c.act_id)?.signed_version);
  }, [me.id, d.amps]);
  async function toggleSelf(l: any, _t: string, on: boolean) {
    if (on) await supabase.from('comp_signoffs').delete().eq('instructor_id', me.id).eq('line_id', l.id).eq('tick_type', 'self');
    else await supabase.from('comp_signoffs').insert({ instructor_id: me.id, line_id: l.id, tick_type: 'self', initials: me.initials || null, source: 'self' });
    await open(comp); reload();
  }
  if (!comp) return (
    <>
      <div className="card">
        <h3>My competencies</h3>
        {d.comps.length ? d.comps.map((c: any) => (
          <button key={c.comp_id} className="rowbtn" onClick={() => open(c)}>
            <span style={{ flex: 1 }}><span className="t">{c.name} (L{c.level})</span><small>{c.done} of {c.total} ticks</small></span><StatusPill status={c.status} />
          </button>
        )) : <p className="muted" style={{ margin: 0 }}>No competencies have been set up yet.</p>}
      </div>
      <div className="card muted" style={{ fontSize: 13 }}><b>Direct</b>: you run it with a Competent instructor beside you. <b>Indirect</b>: a Competent instructor is nearby. <b>Competent</b>: you run it yourself.</div>
    </>
  );
  const fresh = d.comps.find((c: any) => c.comp_id === comp.comp_id) || comp;
  return (
    <>
      <button className="back" onClick={() => setComp(null)}>‹ All competencies</button>
      <div className="card">
        <h3>{fresh.name} (L{fresh.level}) <StatusPill status={fresh.status} /></h3>
        <div>{fresh.done} of {fresh.total} ticks</div>
        <p className="muted" style={{ fontSize: 12.5, margin: '8px 0 0' }}>Tick <b>Self</b> when you think you can do a line. It tells your trainer you are ready to be observed. Grey boxes are not on the form for that line. The other boxes (observations and assessor) are ticked by a manager.</p>
      </div>
      <div className="card">
        {lines.length ? <TickGrid labels={fresh.box_labels} lines={lines} has={(l, t) => (l.auto_from_amp ? ampSigned : ticks.has(l.id + '|' + t))} canClick={(l, t) => t === 'self' && !l.auto_from_amp} onClick={toggleSelf}
          ini={(l, t) => tickInfo.get(l.id + '|' + t)?.initials || ''}
          hint={(l, t) => { const s = tickInfo.get(l.id + '|' + t); return s ? `${s.initials ? s.initials + ' · ' : ''}${s.signed_by || 'You'}${s.observed_on ? ' · ' + s.observed_on : ''}` : (t === 'self' ? 'Tick when you can do this' : 'Ticked by a manager'); }} />
          : <span className="muted">No lines loaded yet.</span>}
      </div>
    </>
  );
}

function Amps({ d, reload }: any) {
  const [sel, setSel] = useState<any>(null); const [amp, setAmp] = useState<any>(null); const [haz, setHaz] = useState<any[]>([]); const [msg, setMsg] = useState('');
  async function open(a: any) {
    setSel(a); setMsg('');
    const [x, h] = await Promise.all([supabase.from('amps').select('*').eq('id', a.amp_id).single(), supabase.from('amp_hazards').select('*').eq('amp_id', a.amp_id).order('sort_order')]);
    setAmp(x.data); setHaz(h.data || []);
  }
  async function ack() {
    const { error } = await supabase.rpc('acknowledge_amp', { p_amp: sel.amp_id });
    if (error) setMsg(error.message); else { await reload(); setSel({ ...sel, up_to_date: true, signed_version: sel.version }); }
  }
  if (!sel) return (
    <div className="card">
      <h3>Activity Management Plans</h3>
      {d.amps.length ? d.amps.map((a: any) => (
        <button key={a.amp_id} className="rowbtn" onClick={() => open(a)}>
          <span><span className="t">{a.title}</span><small>{a.up_to_date ? `Signed version ${a.version} · up to date` : a.signed_version ? `You signed version ${a.signed_version}. Current is version ${a.version}` : 'Not yet signed'}</small></span>
          <Pill kind={a.up_to_date ? 'good' : 'warn'}>{a.up_to_date ? 'Up to date' : a.signed_version ? 'Updated' : 'To sign'}</Pill>
        </button>
      )) : <p className="muted" style={{ margin: 0 }}>No AMPs have been published yet.</p>}
    </div>
  );
  return (
    <>
      <button className="back" onClick={() => { setSel(null); setAmp(null); }}>‹ All AMPs</button>
      {amp && (
        <div className="card amp">
          <h3>{amp.title}</h3>
          <small className="muted">{[amp.folder, amp.activity_number && 'Activity ' + amp.activity_number, 'version ' + amp.version, 'updated ' + fd(amp.updated_at), amp.updated_by && 'by ' + amp.updated_by].filter(Boolean).join(' · ')}</small>
          {amp.change_summary && <div className="hl"><b>What changed in version {amp.version}</b><br />{amp.change_summary}</div>}
          {amp.previous_incidents && <div className="inc"><b>Previous incidents</b><br />{amp.previous_incidents}</div>}
          <dl>{AMP_FIELDS.filter(([k]) => amp[k]).map(([k, l]) => <span key={k} style={{ display: 'contents' }}><dt>{l}</dt><dd>{amp[k]}</dd></span>)}</dl>
          {!!haz.length && (
            <div className="scroll"><table className="haz"><thead><tr><th>Control</th><th>Activity</th><th>Hazard</th><th>Management strategy</th></tr></thead>
              <tbody>{haz.map((h) => <tr key={h.id}><td>{h.control}</td><td>{h.activity_part}</td><td>{h.hazard}</td><td>{h.management_strategy}</td></tr>)}</tbody></table></div>
          )}
        </div>
      )}
      {amp && <AmpMedia ampId={amp.id} />}
      {sel.up_to_date
        ? <div className="card"><div className="check"><span className="dot ok">✓</span>You acknowledged version {sel.version}. Up to date.</div></div>
        : <button className="btn primary" style={{ width: '100%' }} onClick={ack}>I have read and understood this AMP and its incidents</button>}
      <div className="msg bad">{msg}</div>
    </>
  );
}

function Logbook({ me, d }: any) {
  const mine = d.ints;
  return (
    <>
      <div className="card">
        <h3>My logbook</h3>
        <div>{new Set(mine.map((i: any) => i.date)).size} days · {new Set(mine.flatMap((i: any) => i.acts)).size} activities</div>
        <button className="btn primary" style={{ width: '100%', marginTop: 10 }} onClick={() => downloadCsv('logbook-' + me.name.toLowerCase().replace(/\s+/g, '-') + '.csv', intentionRows(mine, d.instructors, d.activities))}>Export my logbook</button>
        <p className="muted" style={{ fontSize: 12.5, margin: '6px 0 0' }}>Downloads a spreadsheet. Yours to keep when you leave.</p>
      </div>
      <div className="card">
        {mine.length ? mine.map((i: any) => (
          <div className="lb" key={i.id}>
            <small>{i.status}{i.called_in_as ? ' · ' + i.called_in_as + ' ' + hm(i.called_in_at) : ''}</small>
            <IntLine i={i} d={d} />
            {i.outcome_of_day && <div>Outcome of the day: {i.outcome_of_day}</div>}
            {i.plan && <small>Plan: {i.plan}</small>}
            {i.debrief_notes && <div><small>Notes: {i.debrief_notes}</small></div>}
          </div>
        )) : <span className="muted">Nothing logged yet.</span>}
      </div>
    </>
  );
}

function Account() {
  const router = useRouter();
  const [pw, setPw] = useState(''); const [msg, setMsg] = useState<[string, string]>(['', '']);
  async function change() {
    if (pw.length < 10) return setMsg(['bad', 'Use at least 10 characters.']);
    const { error } = await supabase.auth.updateUser({ password: pw });
    setMsg(error ? ['bad', error.message] : ['ok', 'Password changed.']); if (!error) setPw('');
  }
  return (
    <div className="card">
      <h3>Account</h3>
      <label className="f" htmlFor="npw">New password</label>
      <input id="npw" type="password" autoComplete="new-password" value={pw} onChange={(e) => setPw(e.target.value)} />
      <div className={'msg ' + msg[0]}>{msg[1]}</div>
      <div className="rowflex"><button className="btn primary" onClick={change}>Change password</button>
        <button className="btn" onClick={async () => { await supabase.auth.signOut(); router.replace('/login'); }}>Sign out</button></div>
      <hr style={{ border: 0, borderTop: '1px solid var(--line)', margin: '14px 0' }} />
      <h3>Put URMA on your home screen</h3>
      <p className="muted" style={{ fontSize: 13.5 }}>
        On an iPhone: tap the share button at the bottom of Safari, then <b>Add to Home Screen</b>.
        On Android: tap the three dots in Chrome, then <b>Add to Home screen</b>. It then opens like an app
        and you stay signed in.
      </p>
    </div>
  );
}

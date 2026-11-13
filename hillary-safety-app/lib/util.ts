import { supabase } from './supabase';

export const SAFE = ['Back at base', 'Off the water', 'Out of the cave', 'In camp'];
export const STATUS: Record<string, string> = { Competent: 'good', Indirect: 'info', Direct: 'warn', 'Not started': 'bad' };
export const PLAN_QUICK = ['HR', 'walk', 'drive', 'via MOSC', 'Taurewa loop', 'OLS', 'TL', 'RTB'];
export const AIM_QUICK = ['Personal growth', 'Forming a team', 'Leadership', 'Resilience', 'Communication', 'Trust'];
const MON = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/** Today's date in New Zealand, as YYYY-MM-DD. */
export const nzToday = () => new Intl.DateTimeFormat('en-CA', { timeZone: 'Pacific/Auckland' }).format(new Date());
/** The time now in New Zealand, as HH:MM. */
export const nzNow = () =>
  new Intl.DateTimeFormat('en-GB', { timeZone: 'Pacific/Auckland', hour: '2-digit', minute: '2-digit', hour12: false }).format(new Date());
export const fd = (d?: string | null) => {
  if (!d) return '';
  const [y, m, x] = d.slice(0, 10).split('-');
  return `${+x} ${MON[+m - 1]} ${y}`;
};
export const hm = (t?: string | null) => (t ? t.slice(0, 5) : '');
export const mins = (t: string) => { const [a, b] = t.split(':'); return +a * 60 + +b; };
export const daysAgo = (n: number) => {
  const d = new Date(nzToday() + 'T12:00:00Z'); d.setUTCDate(d.getUTCDate() - n); return d.toISOString().slice(0, 10);
};

/** Flatten an intention row that was fetched with its two link tables. */
export const INT_SELECT = '*, intention_instructors(instructor_id), intention_activities(act_id)';
export const shapeInt = (r: any) => ({
  ...r,
  who: (r.intention_instructors || []).map((x: any) => x.instructor_id),
  acts: (r.intention_activities || []).map((x: any) => x.act_id),
});

/** Cave, water, mountain and overnight plans are the only ones that are timed and called in. */
export const needsCall = (i: any, activities: any[]) =>
  !!i.overnight || (i.acts || []).some((a: any) => (activities.find((x) => x.id === a)?.call_in_type || 'None') !== 'None');

/** Minutes past the due time with no call-in. Negative or -999 means not overdue. */
export const lateMinutes = (i: any, activities: any[]) => {
  if (i.status === 'Closed' || !i.due_by || !needsCall(i, activities)) return -999;
  const today = nzToday();
  if (i.date > today) return -999;
  const extraDays = i.date < today && !i.overnight ? 1 : 0;
  return mins(nzNow()) + extraDays * 1440 - mins(i.due_by);
};
export const lateLevel = (m: number) => (m > 20 ? 2 : m > 10 ? 1 : 0);

/**
 * Paperwork check. For a set of instructors and activities, look up
 * each person's competency status and whether they have signed the current AMP.
 * The competency used for an activity is its lowest-level one (normally Level 1).
 */
export async function loadChecks(instructorIds: string[], actIds: number[]) {
  const comp: Record<string, string> = {}, amp: Record<string, boolean> = {};
  if (instructorIds.length && actIds.length) {
    const [c, a] = await Promise.all([
      supabase.from('v_competency_status').select('instructor_id,act_id,level,status').in('instructor_id', instructorIds).in('act_id', actIds).order('level', { ascending: false }).limit(5000),
      supabase.from('v_amp_status').select('instructor_id,act_id,up_to_date').in('instructor_id', instructorIds).in('act_id', actIds).limit(5000),
    ]);
    (c.data || []).forEach((r: any) => { comp[r.instructor_id + '|' + r.act_id] = r.status; }); // lowest level wins (written last)
    (a.data || []).forEach((r: any) => { amp[r.instructor_id + '|' + r.act_id] = r.up_to_date; });
  }
  return { comp, amp };
}
export type Checks = { comp: Record<string, string>; amp: Record<string, boolean> };

/** A list of plain-English problems with an intention's paperwork. Empty list = all clear. */
export function issues(i: { who: string[]; acts: number[] }, checks: Checks, instructors: any[], activities: any[]) {
  const out: string[] = [];
  const nm = (id: string) => (instructors.find((x) => x.id === id)?.name || 'Someone').split(' ')[0];
  const an = (id: number) => activities.find((x) => x.id === id)?.name || 'activity';
  i.acts.forEach((a) => {
    const known = i.who.map((w) => checks.comp[w + '|' + a]).filter(Boolean);
    if (known.length && !known.includes('Competent')) out.push('No Competent instructor for ' + an(a));
    i.who.forEach((w) => { if (checks.amp[w + '|' + a] === false) out.push(nm(w) + ' has not signed the current ' + an(a) + ' AMP'); });
  });
  return out;
}

/** Download rows as a spreadsheet file (CSV opens in Excel). */
export function downloadCsv(filename: string, rows: any[][]) {
  const text = rows.map((r) => r.map((c) => '"' + String(c ?? '').replace(/"/g, '""') + '"').join(',')).join('\r\n');
  const blob = new Blob(['﻿' + text], { type: 'text/csv;charset=utf-8' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob); a.download = filename; document.body.appendChild(a); a.click(); a.remove();
  setTimeout(() => URL.revokeObjectURL(a.href), 2000);
}

/** Fetch every row of a big table, 1000 at a time. */
export async function fetchAll(build: () => any, max = 100000) {
  const out: any[] = [];
  for (let from = 0; from < max; from += 1000) {
    const { data, error } = await build().range(from, from + 999);
    if (error) throw error;
    out.push(...(data || []));
    if (!data || data.length < 1000) break;
  }
  return out;
}

export const intentionRows = (list: any[], instructors: any[], activities: any[]) => {
  const nm = (id: string) => instructors.find((x) => x.id === id)?.name || '';
  const an = (id: number) => activities.find((x) => x.id === id)?.name || '';
  return [['Date', 'Instructors', 'Activities', 'Overnight', 'Started', 'Due back', 'Called in at', 'Called in as', 'Pax', 'Group', 'Outcome of the day', 'Plan', 'Status', 'Briefed', 'DM notes', 'Notes after the day', 'Entered later']].concat(
    list.map((i) => [fd(i.date), i.who.map(nm).join(' + '), i.acts.map(an).join(' + '), i.overnight ? 'Yes' : 'No', hm(i.started_at), hm(i.due_by), hm(i.called_in_at), i.called_in_as, i.pax, i.group_name, i.outcome_of_day, i.plan, i.status, i.briefed ? 'Yes' : 'No', i.dm_notes, i.debrief_notes, i.entered_late ? 'Yes' : 'No']),
  );
};

/** Alert sound: three short beeps for yellow, six for red. */
let actx: any = null;
export function beep(n: number) {
  try {
    const AC = (window as any).AudioContext || (window as any).webkitAudioContext;
    actx = actx || new AC();
    if (actx.state === 'suspended') actx.resume();
    for (let k = 0; k < n; k++) {
      const o = actx.createOscillator(), g = actx.createGain();
      o.frequency.value = 880; o.connect(g); g.connect(actx.destination);
      const s = actx.currentTime + k * 0.35;
      g.gain.setValueAtTime(0.3, s); g.gain.exponentialRampToValueAtTime(0.001, s + 0.28);
      o.start(s); o.stop(s + 0.3);
    }
  } catch (e) { /* sound not available */ }
}

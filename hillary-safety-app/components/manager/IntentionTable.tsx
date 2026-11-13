'use client';
import { Pill } from '@/components/ui';
import { needsCall, lateMinutes, lateLevel, issues, fd, hm, Checks } from '@/lib/util';

/** The list of intentions, used on Today's board and in Intention history. */
export default function IntentionTable({ rows, base, checks, showDate, onOpen, actions }: {
  rows: any[]; base: any; checks: Checks; showDate?: boolean; onOpen: (i: any) => void; actions?: (i: any) => React.ReactNode;
}) {
  const nm = (id: string) => base.instructors.find((x: any) => x.id === id)?.name || '?';
  const an = (id: number) => base.activities.find((x: any) => x.id === id)?.name || '?';
  return (
    <div className="scroll">
      <table className="m">
        <thead><tr>{showDate && <th>Date</th>}<th>Instructors</th><th>Activities and plan</th><th>Time</th><th>Pax</th><th>Paperwork</th><th>Briefed</th><th>Status</th><th></th></tr></thead>
        <tbody>
          {rows.length ? rows.map((i) => {
            const n = issues(i, checks, base.instructors, base.activities).length, late = lateMinutes(i, base.activities), lv = lateLevel(late), call = needsCall(i, base.activities);
            return (
              <tr key={i.id} className={'click' + ((n && i.status === 'Waiting') || lv ? ' flag' : '')} onClick={() => onOpen(i)}>
                {showDate && <td style={{ whiteSpace: 'nowrap' }}>{fd(i.date)}</td>}
                <td><b>{i.who.map((w: string) => <div key={w}>{nm(w)}</div>)}</b><small className="muted">{base.centres.find((c: any) => c.id === i.centre_id)?.name}</small></td>
                <td>{i.acts.map(an).join(' + ')}
                  {i.plan && <div><small className="muted">{i.plan}</small></div>}
                  {i.outcome_of_day && <div><small>Outcome of the day: {i.outcome_of_day}</small></div>}
                  {i.debrief_notes && <div><small>Notes: {i.debrief_notes}</small></div>}</td>
                <td style={{ whiteSpace: 'nowrap' }}>
                  {call ? <>{i.started_at ? 'Started ' + hm(i.started_at) : 'Not started yet'}{i.due_by && <div>due {hm(i.due_by)}</div>}</> : <small className="muted">No call-in needed</small>}
                  {i.called_in_at && <div><small className="muted">{i.called_in_as} {hm(i.called_in_at)}</small></div>}
                  {lv > 0 && <div><Pill kind={lv === 2 ? 'bad' : 'warn'}>{lv === 2 ? 'Red' : 'Yellow'} · {late} min overdue</Pill></div>}
                </td>
                <td>{i.pax}</td>
                <td><Pill kind={n ? 'bad' : 'good'}>{n ? n + ' to check' : 'All clear'}</Pill></td>
                <td><Pill kind={i.briefed ? 'good' : 'mute'}>{i.briefed ? 'Yes' : 'No'}</Pill></td>
                <td><Pill kind={i.status === 'Waiting' ? 'warn' : i.status === 'Approved' ? 'good' : 'mute'}>{i.status}</Pill>{i.entered_late && <> <Pill>Entered later</Pill></>}</td>
                <td onClick={(e) => e.stopPropagation()}><div className="rowflex">{actions?.(i)}<button className="btn small" onClick={() => onOpen(i)}>Open</button></div></td>
              </tr>
            );
          }) : <tr><td colSpan={9} className="muted">No intentions to show.</td></tr>}
        </tbody>
      </table>
    </div>
  );
}

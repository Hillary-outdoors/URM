-- URMA · what is actually in the database right now. Run this on its own; it changes nothing.
select 'centres' as table, count(*) from centres
union all select 'instructors', count(*) from instructors
union all select 'qualifications_held', count(*) from qualifications_held
union all select 'activities', count(*) from activities
union all select 'amps', count(*) from amps
union all select 'amp_hazards', count(*) from amp_hazards
union all select 'competencies', count(*) from competencies
union all select 'competency_lines', count(*) from competency_lines
union all select 'comp_signoffs', count(*) from comp_signoffs
union all select 'activity_comps', count(*) from activity_comps
order by 1;

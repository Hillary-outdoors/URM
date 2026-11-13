-- =====================================================================
-- RUN ONCE, after you have created the manager login in Supabase
-- (Authentication > Users > Add user). See the setup guide, step 4.
--
-- Change the email below to the manager login's email, then run it.
-- =====================================================================
insert into instructors (auth_user_id, name, account_type)
select id, 'Manager', 'manager'
from auth.users
where email = 'CHANGE-ME@example.com';

-- Check it worked: this should show one row.
select name, account_type from instructors where account_type = 'manager';

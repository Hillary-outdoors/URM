-- URMA · step 19 · Point each person at the login they already have
--
-- These Supabase accounts already exist; this only tells the app which instructor row each one is.
-- Nobody's password changes and no account is created. Safe to run again.
-- A name that has no account, or an account whose email is not listed here, is simply left alone.
begin;

create temp table _login (name text, email text) on commit drop;
insert into _login values
  ('Alex Booker','alex.booker5959@gmail.com'),
  ('Alex Manning','alexm@hillaryoutdoors.co.nz'),
  ('Amy Brown','amyb@hillaryoutdoors.co.nz'),
  ('Blake Nicklin','blaken@hillaryoutdoors.co.nz'),
  ('Caitlin Gillespie','caitling@hillaryoutdoors.co.nz'),
  ('Caleb Squire','calebs@hillaryoutdoors.co.nz'),
  ('Catherine Maclure','catttmac@gmail.com'),
  ('Charlie Doak','charlied@hillaryoutdoors.co.nz'),
  ('Cluver Swart','cluvers@hillaryoutdoors.co.nz'),
  ('Dylan Grace','dylang@hillaryoutdoors.co.nz'),
  ('Eliza-jane Page','ej@hillaryoutdoors.co.nz'),
  ('Ellie Aldersley','elliea@hillaryoutdoors.co.nz'),
  ('Flynn Taylor','flynnt@hillaryoutdoors.co.nz'),
  ('Grace Saywell','gracie.jane.robertson@gmail.com'),
  ('Graeme Swift','graemes@hillaryoutdoors.co.nz'),
  ('Gregor Gray','gregg@hillaryoutdoors.co.nz'),
  ('Hayden Devine','haydend@hillaryoutdoors.co.nz'),
  ('Heather Niccoll','heather@hillaryoutdoors.co.nz'),
  ('Huw Standen','huw.standen@hotmail.com'),
  ('Josh Hart','joshh@hillaryoutdoors.co.nz'),
  ('Joshua Murphy','joshuam@hillaryoutdoors.co.nz'),
  ('Julian Vanderput','julianv@hillaryoutdoors.co.nz'),
  ('Lauren Harris','laurenh@hillaryoutdoors.co.nz'),
  ('Leo Jones','ljonesbeach@gmail.com'),
  ('Lina Vansevenant','linav@hillaryoutdoors.co.nz'),
  ('Melissa Harris','melissah@hillaryoutdoors.co.nz'),
  ('Owen Raffan','owen.raffan@gmail.com'),
  ('Patsy Ryan-Betts','patsyb@hillaryoutdoors.co.nz'),
  ('Prajot Sabnis','prajots@hillaryoutdoors.co.nz'),
  ('Richard Purvis','richardp@hillaryoutdoors.co.nz'),
  ('Sarah Buckingham','sarahb@hillaryoutdoors.co.nz'),
  ('Sash Nukada','sashn@hillaryoutdoors.co.nz'),
  ('Sebastian Teague','sebt@hillaryoutdoors.co.nz'),
  ('Todd Elliott','todd@hillaryoutdoors.co.nz'),
  ('Zoe Revell-Lynch','zoer@hillaryoutdoors.co.nz');

update instructors i
set auth_user_id = u.id
from _login v join auth.users u on lower(u.email) = lower(v.email)
where lower(i.name) = lower(v.name)
  and i.auth_user_id is null;

commit;

-- who is now linked, and who still has no login:
select i.name, i.employment, coalesce(u.email, '— no login yet —') as login
from instructors i
left join auth.users u on u.id = i.auth_user_id
where i.account_type = 'instructor' and i.employment <> 'Past staff'
order by (u.email is null) desc, i.name;

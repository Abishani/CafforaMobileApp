-- Example negative checks. Run with Supabase's SQL editor or pgTAP after
-- authenticating as the corresponding role; the statements must fail.
-- Registered user must not write MenuItems:
-- insert into public."MenuItems" (name) values ('Unauthorized item');
-- update public."MenuItems" set name = 'Unauthorized update' where id = '<menu-id>';
-- delete from public."MenuItems" where id = '<menu-id>';
-- Registered user must not update Orders.status:
-- update public."Orders" set status = 'completed' where id = '<own-order-id>';
-- Anonymous/guest must not insert Orders:
-- insert into public."Orders" (user_id) values (auth.uid());

-- Registered user must not fetch another customer's order by direct ID:
-- select * from public."Orders" where id = '<another-users-order-id>';
-- Expected: zero rows, because the RLS SELECT predicate includes user_id = auth.uid().

-- Admin-only API bypass test from any authenticated non-admin client:
-- await supabase.from('MenuItems').insert({'name': 'Unauthorised API item'});
-- Expected: PostgrestException / permission denied by row-level security.

-- Expected result for each statement above: permission denied by row-level
-- security policy (or zero rows affected where the policy filters the row).
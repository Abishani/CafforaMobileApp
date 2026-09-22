-- Run after enabling RLS. Adjust primary-key column names if your schema differs.
alter table public."Users" enable row level security;
alter table public."MenuItems" enable row level security;
alter table public."Orders" enable row level security;
alter table public."OrderItems" enable row level security;

create or replace function public.current_user_role()
returns text language sql stable security definer set search_path = public
as $$ select role from public."Users" where id = auth.uid() $$;

create policy "menu items are public read only" on public."MenuItems"
for select using (true);
create policy "admins manage menu items" on public."MenuItems"
for all using (public.current_user_role() = 'admin')
with check (public.current_user_role() = 'admin');

create policy "registered users create own orders" on public."Orders"
for insert to authenticated
with check (public.current_user_role() = 'registered' and user_id = auth.uid());
create policy "registered users read own orders" on public."Orders"
for select to authenticated
using (public.current_user_role() = 'registered' and user_id = auth.uid());
create policy "admins read orders" on public."Orders"
for select to authenticated using (public.current_user_role() = 'admin');
create policy "admins update order status" on public."Orders"
for update to authenticated
using (public.current_user_role() = 'admin')
with check (public.current_user_role() = 'admin');

-- Restrict the authenticated table privilege to the status column so the
-- policy above cannot be used to change customer ownership or order totals.
revoke update on public."Orders" from authenticated;
grant update (status) on public."Orders" to authenticated;

create policy "registered users read own order items" on public."OrderItems"
for select to authenticated
using (exists (select 1 from public."Orders" o where o.id = "OrderItems".order_id and o.user_id = auth.uid() and public.current_user_role() = 'registered'));
create policy "admins read all order items" on public."OrderItems"
for select to authenticated
using (public.current_user_role() = 'admin');

-- Optional view used by reporting clients for one-query totals.
create or replace view public."OrderTotals" as
select o.id as order_id, o.user_id, o.status, o.created_at,
	   coalesce(sum(oi.quantity * oi.unit_price), 0) as total_price,
	   coalesce(sum(oi.quantity), 0) as item_count
from public."Orders" o
left join public."OrderItems" oi on oi.order_id = o.id
group by o.id;
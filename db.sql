-- Demo guestbook for the Snapshot app demo. The page talks to this directly
-- with the PUBLIC anon key; RLS scopes access to exactly this table.
create table if not exists demo_guestbook (
  id          bigint generated always as identity primary key,
  name        text not null default 'anon',
  message     text not null,
  created_at  timestamptz not null default now()
);
alter table demo_guestbook enable row level security;
create policy "demo_read"   on demo_guestbook for select using (true);
create policy "demo_insert" on demo_guestbook for insert
  with check (char_length(message) between 1 and 280 and char_length(name) <= 40);

-- Demo guestbook for the Snapshot app demo.
--
-- Safety model (browser talks to Supabase directly with the PUBLIC anon key —
-- there is NO server in between, so every rule below is enforced in Postgres):
--   • anon can READ only (id, name, message, created_at) — never the IP/owner
--     hashes (column-level GRANT hides them).
--   • anon has NO direct insert/update/delete — all writes go through two
--     SECURITY DEFINER functions that enforce the limits, so a crafted request
--     to the table can't bypass them.
--   • add_guestbook(): length caps + per-IP rate limit (3/min, 20/day) + a hard
--     500-row total cap (oldest pruned) so storage can't be flooded.
--   • delete_guestbook(): only the holder of the per-browser token that created
--     a row can delete it (token hash compared server-side).
--   • IPs and tokens are only ever stored as salted SHA-256 hashes.
-- Idempotent — safe to re-run.

create extension if not exists pgcrypto;

create table if not exists demo_guestbook (
  id          bigint generated always as identity primary key,
  name        text not null default 'anon',
  message     text not null,
  owner_hash  text,                 -- sha256(per-browser token + salt) — for delete
  ip_hash     text,                 -- sha256(client ip + salt) — for rate limiting
  created_at  timestamptz not null default now(),
  constraint gb_name_len    check (char_length(name) <= 40),
  constraint gb_message_len check (char_length(message) between 1 and 280)
);
-- bring an older table (id/name/message/created_at only) up to date
alter table demo_guestbook add column if not exists owner_hash text;
alter table demo_guestbook add column if not exists ip_hash    text;
create index if not exists gb_created_idx on demo_guestbook (created_at desc);
create index if not exists gb_ip_idx      on demo_guestbook (ip_hash, created_at desc);

alter table demo_guestbook enable row level security;

-- READ: bounded column set only; the hashes are never selectable by anon.
revoke all on demo_guestbook from anon, authenticated;
grant select (id, name, message, created_at) on demo_guestbook to anon, authenticated;
drop policy if exists demo_read   on demo_guestbook;
drop policy if exists demo_insert on demo_guestbook;
drop policy if exists gb_read     on demo_guestbook;
create policy gb_read on demo_guestbook for select to anon, authenticated using (true);
-- (no insert/update/delete policies → writes are only possible via the functions)

-- client IP from the request headers PostgREST exposes (best-effort).
create or replace function _gb_ip() returns text
language sql stable as $$
  select coalesce(
    nullif(btrim(split_part(
      current_setting('request.headers', true)::json->>'x-forwarded-for', ',', 1)), ''),
    current_setting('request.headers', true)::json->>'cf-connecting-ip',
    'unknown');
$$;

create or replace function _gb_hash(p text) returns text
language sql immutable as $$
  select encode(digest(coalesce(p,'') || ':snapshot-guestbook-v1', 'sha256'), 'hex');
$$;

-- POST a message. Validates, rate-limits per IP, caps total rows. Returns new id.
create or replace function add_guestbook(p_name text, p_message text, p_token text)
returns bigint
language plpgsql security definer set search_path = public as $$
declare
  v_ip   text := _gb_ip();
  v_iph  text := _gb_hash(v_ip);
  v_name text := left(coalesce(nullif(btrim(p_name), ''), 'anon'), 40);
  v_msg  text := btrim(coalesce(p_message, ''));
  v_id   bigint;
begin
  if char_length(v_msg) < 1 then raise exception 'Message is empty.'; end if;
  if char_length(v_msg) > 280 then raise exception 'Message is too long (280 max).'; end if;
  -- per-IP burst + daily limits (skip the shared "unknown" bucket)
  if v_ip <> 'unknown' then
    if (select count(*) from demo_guestbook
          where ip_hash = v_iph and created_at > now() - interval '60 seconds') >= 3 then
      raise exception 'Slow down — too many messages in a row.';
    end if;
    if (select count(*) from demo_guestbook
          where ip_hash = v_iph and created_at > now() - interval '1 day') >= 20 then
      raise exception 'Daily limit reached for this guestbook.';
    end if;
  end if;
  insert into demo_guestbook (name, message, owner_hash, ip_hash)
  values (v_name, v_msg,
          case when coalesce(p_token,'') = '' then null else _gb_hash(p_token) end,
          v_iph)
  returning id into v_id;
  -- hard storage cap: keep only the newest 500 rows
  delete from demo_guestbook
   where id in (select id from demo_guestbook order by created_at desc offset 500);
  return v_id;
end $$;

-- DELETE your own message — only the browser token that created it can.
create or replace function delete_guestbook(p_id bigint, p_token text)
returns boolean
language plpgsql security definer set search_path = public as $$
declare v_n int;
begin
  if coalesce(p_token,'') = '' then return false; end if;
  delete from demo_guestbook where id = p_id and owner_hash = _gb_hash(p_token);
  get diagnostics v_n = row_count;
  return v_n > 0;
end $$;

revoke all on function add_guestbook(text,text,text)    from public;
revoke all on function delete_guestbook(bigint,text)     from public;
revoke all on function _gb_ip()                          from public;
revoke all on function _gb_hash(text)                    from public;
grant execute on function add_guestbook(text,text,text)  to anon, authenticated;
grant execute on function delete_guestbook(bigint,text)  to anon, authenticated;

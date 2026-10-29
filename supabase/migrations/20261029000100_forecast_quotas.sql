-- Apply before deploying generate-forecast. Only the server's service_role can reserve quota.
begin;
create schema if not exists private;
create table if not exists private.forecast_quota_buckets (
  scope text not null check (scope in ('user-minute', 'user-day', 'global-day')),
  subject text not null,
  user_id uuid references auth.users(id) on delete cascade,
  bucket timestamptz not null,
  used integer not null default 0 check (used >= 0),
  primary key (scope, subject, bucket)
);
create index if not exists forecast_quota_expiry on private.forecast_quota_buckets(bucket);
alter table private.forecast_quota_buckets enable row level security;
revoke all on private.forecast_quota_buckets from public, anon, authenticated;

create or replace function public.consume_forecast_quota(
  p_user_id uuid,
  p_minute_limit integer default 3,
  p_daily_limit integer default 20,
  p_global_daily_limit integer default 500
) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  t_now timestamptz := now();
  t_minute timestamptz := date_trunc('minute', t_now);
  t_day timestamptz := date_trunc('day', t_now at time zone 'UTC') at time zone 'UTC';
  n_minute integer;
  n_day integer;
  n_global integer;
begin
  if p_user_id is null or p_minute_limit not between 1 and 100 or p_minute_limit is null
    or p_daily_limit not between 1 and 10000 or p_daily_limit is null
    or p_global_daily_limit not between 1 and 100000 or p_global_daily_limit is null then
    raise exception 'Invalid quota configuration';
  end if;
  -- All three counters are checked and incremented within a single serialized transaction.
  perform pg_catalog.pg_advisory_xact_lock(748125963021::bigint);
  select coalesce((select used from private.forecast_quota_buckets where scope = 'user-minute' and subject = p_user_id::text and bucket = t_minute), 0) into n_minute;
  select coalesce((select used from private.forecast_quota_buckets where scope = 'user-day' and subject = p_user_id::text and bucket = t_day), 0) into n_day;
  select coalesce((select used from private.forecast_quota_buckets where scope = 'global-day' and subject = 'all' and bucket = t_day), 0) into n_global;
  if n_day >= p_daily_limit or n_global >= p_global_daily_limit then
    return jsonb_build_object('allowed', false, 'retry_after_seconds', greatest(1, ceil(extract(epoch from t_day + interval '1 day' - t_now))::integer));
  end if;
  if n_minute >= p_minute_limit then
    return jsonb_build_object('allowed', false, 'retry_after_seconds', greatest(1, ceil(extract(epoch from t_minute + interval '1 minute' - t_now))::integer));
  end if;
  insert into private.forecast_quota_buckets(scope, subject, user_id, bucket, used) values
    ('user-minute', p_user_id::text, p_user_id, t_minute, 1),
    ('user-day', p_user_id::text, p_user_id, t_day, 1),
    ('global-day', 'all', null, t_day, 1)
  on conflict (scope, subject, bucket) do update set used = private.forecast_quota_buckets.used + 1;
  delete from private.forecast_quota_buckets where bucket < t_day - interval '2 days';
  return jsonb_build_object('allowed', true);
end;
$$;
revoke all on function public.consume_forecast_quota(uuid, integer, integer, integer) from public, anon, authenticated;
grant execute on function public.consume_forecast_quota(uuid, integer, integer, integer) to service_role;
commit;

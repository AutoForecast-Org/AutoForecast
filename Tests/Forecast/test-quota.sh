#!/bin/bash
# Isolated, temporary PostgreSQL cluster. Does not connect to the Supabase project.
set -euo pipefail
cd "$(dirname "$0")/../.."
pg_bin="${PG_BIN:-/opt/homebrew/opt/postgresql@17/bin}"
test_dir=$(mktemp -d /tmp/autoforecast-quota.XXXXXX)
"$pg_bin/initdb" -D "$test_dir/data" --no-locale --encoding=UTF8 --auth=trust > "$test_dir/init.log"
"$pg_bin/pg_ctl" -D "$test_dir/data" -l "$test_dir/server.log" -o "-k $test_dir -h '' -p 55439" -w start > /dev/null
trap '"$pg_bin/pg_ctl" -D "$test_dir/data" -m immediate stop > /dev/null 2>&1' EXIT
export PGHOST="$test_dir" PGPORT=55439 PGDATABASE=postgres
psql_cmd=("$pg_bin/psql" -X -v ON_ERROR_STOP=1)
"${psql_cmd[@]}" > "$test_dir/setup.log" <<'SQL'
create role anon;
create role authenticated;
create role service_role;
create schema auth;
create table auth.users(id uuid primary key);
insert into auth.users values ('11111111-1111-4111-8111-111111111111'), ('22222222-2222-4222-8222-222222222222');
SQL
"${psql_cmd[@]}" -f supabase/migrations/20261029000100_forecast_quotas.sql >> "$test_dir/setup.log"
"${psql_cmd[@]}" > "$test_dir/assertions.log" <<'SQL'
do $$ begin
  if has_function_privilege('anon', 'public.consume_forecast_quota(uuid,integer,integer,integer)', 'execute') then raise exception 'anon can reserve quota'; end if;
  if has_function_privilege('authenticated', 'public.consume_forecast_quota(uuid,integer,integer,integer)', 'execute') then raise exception 'client can reserve quota'; end if;
end $$;
set role service_role;
do $$ begin
  if not (public.consume_forecast_quota('11111111-1111-4111-8111-111111111111',1,20,500)->>'allowed')::boolean then raise exception 'first request denied'; end if;
  if (public.consume_forecast_quota('11111111-1111-4111-8111-111111111111',1,20,500)->>'allowed')::boolean then raise exception 'minute limit bypassed'; end if;
end $$;
reset role;
truncate private.forecast_quota_buckets;
set role service_role;
do $$ begin
  perform public.consume_forecast_quota('11111111-1111-4111-8111-111111111111',100,1,500);
  if (public.consume_forecast_quota('11111111-1111-4111-8111-111111111111',100,1,500)->>'allowed')::boolean then raise exception 'daily limit bypassed'; end if;
end $$;
reset role;
truncate private.forecast_quota_buckets;
set role service_role;
do $$ begin
  perform public.consume_forecast_quota('11111111-1111-4111-8111-111111111111',100,20,1);
  if (public.consume_forecast_quota('22222222-2222-4222-8222-222222222222',100,20,1)->>'allowed')::boolean then raise exception 'global limit bypassed'; end if;
end $$;
reset role;
truncate private.forecast_quota_buckets;
SQL
pids=()
for attempt in {1..10}; do
  "${psql_cmd[@]}" -c "set role service_role; select public.consume_forecast_quota('11111111-1111-4111-8111-111111111111',3,20,500);" > "$test_dir/concurrent-$attempt.log" &
  pids+=("$!")
done
for process_id in "${pids[@]}"; do wait "$process_id"; done
"${psql_cmd[@]}" >> "$test_dir/assertions.log" <<'SQL'
do $$ begin
  if (select used from private.forecast_quota_buckets where scope='user-day') <> 3 then raise exception 'concurrent limit bypassed'; end if;
  if (select used from private.forecast_quota_buckets where scope='global-day') <> 3 then raise exception 'global counter inconsistent'; end if;
end $$;
delete from auth.users where id='11111111-1111-4111-8111-111111111111';
do $$ begin
  if exists(select from private.forecast_quota_buckets where user_id is not null) then raise exception 'user counters not deleted'; end if;
end $$;
SQL
printf 'PASS: SQL permissions, per-minute/daily/global limits, ten concurrent admissions, user deletion cascade\n'

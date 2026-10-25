begin;
select plan(4);

select has_extension('postgis', 'postgis is installed');
select has_extension('pg_cron', 'pg_cron is installed');
select has_extension('pg_net', 'pg_net is installed');
select ok(
  st_dwithin(
    'SRID=4326;POINT(92.1731 22.6533)'::geography,
    'SRID=4326;POINT(92.1800 22.6600)'::geography,
    2000
  ),
  'st_dwithin works on geography'
);

select * from finish();
rollback;

install spatial; load spatial;
select * exclude(position), ST_GeomFromHEXEWKB(position) as position from radar
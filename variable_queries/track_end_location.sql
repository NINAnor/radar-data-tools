load spatial;

attach '${DATABASE_PATH}' as db;

select st_startpoint(trajectory) from db.main.track limit 1;

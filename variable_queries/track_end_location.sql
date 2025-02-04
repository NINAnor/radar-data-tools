load spatial;

attach '${DATABASE_PATH}' as db (READ_ONLY);

select st_startpoint(trajectory) from db.main.track limit 1;

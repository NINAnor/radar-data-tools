load spatial;

attach '${DATABASE_PATH}' as db;

select st_length_spheroid(st_makeline(st_startpoint(trajectory), st_endpoint(trajectory))) / st_length_spheroid(trajectory) from db.main.track limit 1;

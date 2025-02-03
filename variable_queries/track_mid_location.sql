load spatial;

attach '${DATABASE_PATH}' as db;

select trajectory, st_pointN(trajectory, floor(st_numPoints(trajectory) / 2)) from db.main.track limit 1;

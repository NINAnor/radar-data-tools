load spatial;

attach '${DATABASE_PATH}' as db (READ_ONLY);

select st_endpoint(trajectory) from db.main.track limit 1;

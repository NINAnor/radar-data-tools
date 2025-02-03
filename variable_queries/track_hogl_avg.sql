load spatial;

set memory_limit = '4GB';

attach '${DATABASE_PATH}' as db;
attach '${POINT_DATABASE}' as po_db;

select id, location, radar_name, year, month from db.main.track limit 1;

select 
    id,
    avg(hogl) as avg_hogl 
from po_db.main.track_point 
where id = 7803850 and location = 'lista' and year = 2023 and month = '04'
group by id, location, year


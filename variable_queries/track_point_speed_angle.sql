load spatial;

set memory_limit = '4GB';

attach '${DATABASE_PATH}' as db;
attach '${POINT_DATABASE}' as po_db;


select 
    p1.id,
    p1.index_nr,
    p1.timestamp,
    p2.id,
    p2.index_nr,
    p2.timestamp,
    (
        st_distance_spheroid(p2.geom, p1.geom) / 
        extract(epoch from (p2.timestamp - p1.timestamp))
    ) as speed,
    (atan2(st_y(p2.geom) - st_y(p1.geom), st_x(p2.geom) - st_x(p1.geom)) + 360) % 360 as theta
from po_db.main.track_point as p1
join po_db.main.track_point as p2 
on 
    p1.id = p2.id and 
    p1.location = p2.location AND
    p1.month = p2.month AND
    p1.year = p2.year and
    p1.index_nr = p2.index_nr - 1
where p1.id = 7803850 and p1.location = 'lista' and p1.year = 2023 and p1.month = '04'
order by p1.index_nr
-- group by id



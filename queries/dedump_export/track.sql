install spatial; load spatial;
select 
    * exclude(trajectory), 
    ST_Force3DZ(ST_GeomFromHEXEWKB(trajectory), -99999) as trajectory,
    list_transform(st_dump(st_points(ST_GeomFromHEXEWKB(trajectory))), str -> st_m(str.geom)) as m_dimension
from track
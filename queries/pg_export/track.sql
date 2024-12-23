install postgres;
load postgres;
install spatial;
load spatial;

ATTACH '' AS pgdb (TYPE POSTGRES, READ_ONLY, SCHEMA '$schema');
COPY (
    SELECT 
        * exclude(trajectory), 
        ST_Force3DZ(ST_GeomFromHEXEWKB(trajectory), -99999) as trajectory,
        list_transform(st_dump(st_points(ST_GeomFromHEXEWKB(trajectory))), str -> st_m(str.geom)) as m_dimension
    FROM pgdb."$table"
) TO '$dest_path/$table.parquet' (format parquet, overwrite true, CODEC zstd)

LOAD spatial;
select
    st_x (geom) as x,
    st_y (geom) as y
from
    read_parquet('$parquet_source_path')
order by "id", "index_nr"

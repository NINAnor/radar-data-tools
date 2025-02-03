SET enable_progress_bar = true;

install spatial;
load spatial;

create table if not exists track_point as (
    select 
        pts.*,
        hogl.hogl 
    from
        read_parquet('${db_path}track_point/${PARQUET_FILE}', hive_partitioning = true) as pts
    join read_parquet('${db_path}track_point_hogl/${PARQUET_FILE}', hive_partitioning = true) as hogl on 
        pts.id = hogl.id and 
        pts.internal_id = hogl.internal_id and 
        pts.index_nr = hogl.index_nr and
        pts.radar_name = hogl.radar_name and
        pts.location = hogl.location and
        pts.year = hogl.year AND
        pts.month = hogl.month
    where 0 = 1
);

insert into track_point from (
    select 
        pts.*,
        hogl.hogl 
    from
        read_parquet('${db_path}track_point/${PARQUET_FILE}', hive_partitioning = true) as pts
    join read_parquet('${db_path}track_point_hogl/${PARQUET_FILE}', hive_partitioning = true) as hogl on 
        pts.id = hogl.id and 
        pts.internal_id = hogl.internal_id and 
        pts.index_nr = hogl.index_nr and
        pts.radar_name = hogl.radar_name and
        pts.location = hogl.location and
        pts.year = hogl.year AND
        pts.month = hogl.month
);
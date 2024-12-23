load spatial;

COPY (
    with lines as (
        from read_parquet("$parquet_source_path")
        where id >= $start_id
        order by id
        limit $chunk
    ),
    points as (
        select id, internal_id, unnest(st_dump(ST_Points(trajectory)), recursive := true) as geom
        from lines
    ), cleaned_points as (
        select
            id,
            internal_id,
            ST_Force3DZ(geom, -99999) as geom,
            -- ST_M(geom) as m,
            path[1] as index
        from points
    )
    select
        cp.id,
        cp.internal_id as internal_id,
        cp.index as index_nr,
        cp.geom,
        -- cp.m,
        timestamp_start + interval (
            trj_time.trajectory_time[cp.index]
        ) seconds as timestamp
    from cleaned_points as cp
    left join (
        select id, timestamp_start, trajectory_time
        from lines
    ) as trj_time on trj_time.id = cp.id
) TO "$parquet_dest_path/$index.parquet" (format parquet, overwrite true, CODEC zstd);
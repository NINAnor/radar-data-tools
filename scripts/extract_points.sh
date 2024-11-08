parquet_source_path=$1
parquet_dest_path=$2
chunk=$3
index=$4
start_id=$5

select=$(cat <<EOF
with points as (
        select id, unnest(st_dump(ST_Points(trajectory)), recursive := true) as geom
        from "$parquet_source_path"
        where id >= $start_id
        order by id
        limit $chunk
    ), cleaned_points as (
        select
            id,
            ST_Force3DZ(geom, -99999) as geom,
            ST_M(geom) as m,
            path[1] as index
        from points
    )
    select
        cp.id,
        cp.index,
        cp.geom,
        cp.m,
        timestamp_start + interval (
            trj_time.trajectory_time[cp.index]
        ) seconds as timestamp,
        ST_Transform(cp.geom, 'EPSG:4326', 'EPSG:25835') as geom_25835
    from cleaned_points as cp
    left join (
        select id, timestamp_start, trajectory_time
        from "$parquet_source_path"
        where id >= $start_id
        order by id
        limit $chunk
    ) as trj_time on trj_time.id = cp.id
EOF
)

echo $select;

query=$(cat <<EOF
SET memory_limit = '$MAX_MEM';
SET enable_progress_bar = true;

COPY ($select) TO "$parquet_dest_path/$index.parquet" (format parquet,
overwrite true, CODEC 'zstd');
EOF
)
duckdb ":memory:" "LOAD spatial; $query"

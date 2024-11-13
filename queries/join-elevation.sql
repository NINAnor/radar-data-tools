LOAD spatial;
copy (
    with elevation as (
        select column0 as elevation, (row_number() over ()) as row_number from read_csv('/dev/stdin')
    ), points as (
        select
            *, 
            (row_number() over(order by id, index_nr)) as row_number 
        from read_parquet("$parquet_source_path")
    )
    select 
        p.*,
        (st_z(p.geom) - e.elevation) as hogl
    from points as p 
    join elevation as e on p.row_number = e.row_number
    order by p.row_number
) to "$destination_path" (format parquet, overwrite true, CODEC zstd);
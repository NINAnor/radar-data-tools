LOAD spatial;
copy (
    with elevation as (
        select try_cast(column0 as double) as elevation, (row_number() over ()) as row_number from read_csv('/dev/stdin', header = false)
    ), points as (
        select
            *, 
            (row_number() over(order by id, index_nr)) as row_number 
        from read_parquet("$parquet_source_path")
    )
    select 
        p.id,
        p.internal_id,
        p.index_nr,
        CASE 
            WHEN e.elevation is null THEN null
            ELSE (st_z(p.geom) - e.elevation)
        END as hogl,
        '$elevation_model_path' as computed_from_path,
        now() as created_at
    from points as p 
    left join elevation as e on p.row_number = e.row_number
    order by p.row_number
) to "$destination_path" (format parquet, overwrite true, CODEC zstd);
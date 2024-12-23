INSTALL spatial; LOAD spatial;

with ordered as (
    SELECT id, (row_number() over(order by id) -1) as index from read_parquet("$parquet_source") order by id
)
select row_number() over(order by id) as idx, id from ordered where index % $chunk_size = 0 order by id

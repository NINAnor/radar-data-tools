#!/bin/bash

source_path=$1
elevation_path=$2
dest_path=$3

query=$(cat <<EOF
COPY (select 
    s.*,
    st_z(s.geom) - c.elevation as hagl,
    st_z(s.geom) as hasl
    from read_parquet("$source_path") as s 
    join (from read_parquet("$elevation_path")) as c 
        on s.id = c.id and s.index_nr = c.index_nr
) TO "$dest_path" (format parquet, overwrite true, CODEC 'zstd');
EOF
)

duckdb ":memory:" "LOAD spatial; $query"

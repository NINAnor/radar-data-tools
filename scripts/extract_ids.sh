#!/bin/bash

select=$(cat <<EOF
    with ordered as (
        SELECT id, (row_number() over(order by id) -1) as index from "$2" order by id
    )
    select row_number() over(order by id) as idx, id from ordered where index % $3 = 0 order by id
EOF
)

query=$(cat <<EOF
SET memory_limit = '$MAX_MEM';
SET enable_progress_bar = true;

COPY ($select) TO "$1" (header false);
EOF
)
duckdb ":memory:" "LOAD spatial; $query"

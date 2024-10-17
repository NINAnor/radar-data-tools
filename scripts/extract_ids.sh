
select=$(cat <<EOF
    select id
    from "$1.parquet"
    order by id
EOF
)

query=$(cat <<EOF
SET memory_limit = '2GB';
SET enable_progress_bar = true;

COPY ($select) TO "$1-ids.csv" (header false);
EOF
)
duckdb ":memory:" "LOAD spatial; $query"

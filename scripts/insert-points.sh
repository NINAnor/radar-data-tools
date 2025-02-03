
export db_path=$1
point_db=$2
export PARQUET_FILE=$3

duckdb $point_db "$(envsubst <queries/insert-points.sql)"

#!/bin/bash
export parquet_source_path=$1
export elevation_model_path=$2
export destination_path=$3
export hogl_csv=$4

duckdb -csv -noheader -separator " " ":memory:" "$(envsubst <queries/get-row-coordinates.sql)" |
gdallocationinfo -wgs84 -b 1 -valonly -E -field_sep , $2 > $4
duckdb ":memory:" "$(envsubst <queries/join-elevation.sql)"
rm $4

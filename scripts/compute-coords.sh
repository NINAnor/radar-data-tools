#!/bin/bash
export parquet_source_path=$1
elevation_model_path=$2
export destination_path=$3

duckdb -csv -noheader -separator " " ":memory:" "$(envsubst <queries/get-row-coordinates.sql)" |
gdallocationinfo -wgs84 -b 1 -valonly $2 |
duckdb ":memory:" "$(envsubst <queries/join-elevation.sql)"

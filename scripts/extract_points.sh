#!/bin/bash

export parquet_source_path=$1
export parquet_dest_path=$2
export chunk=$3
export index=$4
export start_id=$5

duckdb ":memory:" "$(envsubst <queries/extract-points.sql)"

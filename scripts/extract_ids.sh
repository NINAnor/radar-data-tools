#!/bin/bash

export destination_path=$1
export parquet_source=$2
export chunk_size=$3

duckdb ":memory:" "$(envsubst <queries/get-partition-id.sql)"

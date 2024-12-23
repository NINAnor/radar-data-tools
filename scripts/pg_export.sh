#!/bin/bash

export schema=$1
export table=$2
export dest_path=$3

query_file="queries/pg_export/$table.sql"

if [ ! -f $query_file ]; then
    query_file="queries/pg_export/default.sql"
fi

echo "Using $query_file"

duckdb ":memory:" "$(envsubst <$query_file)"

#!/bin/bash

set -e

export db_path=$1
name=$2

point_db="${1}${2}-points.duckdb"

duckdb "${1}${2}.duckdb" "$(envsubst <queries/materialize.sql)"

find "${db_path}track_point/" -name "*.parquet" -printf "%P\n" | parallel -j1 --bar --joblog points.log --resume --halt-on-error 2 --resume-failed ./scripts/insert-points.sh $db_path $point_db {} ::::

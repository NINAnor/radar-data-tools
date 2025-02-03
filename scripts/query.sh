#!/bin/bash

set -e

export BASE_PATH=$1
export DATABASE_PATH="${1}${2}.duckdb"
export POINT_DATABASE="${1}${2}-points.duckdb"

echo $DB_DATABASE
echo $POINT_DATABASE

RESULT=$(envsubst <"${3}")
echo $RESULT
duckdb :memory: "$RESULT"


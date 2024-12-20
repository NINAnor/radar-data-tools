#!/bin/bash

export db_path=$1
name=$2

duckdb "$1/$2" "$(envsubst <queries/materialize.sql)"

#!/bin/bash

r.import input=$1 output=elevation
v.import input=$2 layer=$3 output=track_points
g.region -p vector=track_points@PERMANENT align=elevation@PERMANENT
v.db.addcolumn track_points@PERMANENT columns="elevation double precision"
v.what.rast map=track_points@PERMANENT raster=elevation@PERMANENT column=elevation
v.out.ogr input=track_points@PERMANENT format=Parquet output=$4

# Read variables from .env file (optionally)
-include .env
export

.PHONY: extract-points generate-ids generate-parquet clean clean-grass generate-height join-result

# Declare variables
# variables can be overridden while calling make

# DB to use
PG_DBNAME = utsira_max_1

output_dir := output/$(PG_DBNAME)

# Always read table with this name
tracks_table := track

# Extracted points will be put in this table
track_points_table := track_points

# Configuration for the schema based on the year/month
YEAR = 2019
MONTH = 10
SCHEMA = m$(YEAR)$(MONTH)


tracks_dir := $(output_dir)/$(tracks_table).parquet/year=$(YEAR)/month=$(MONTH)
tracks_points_dir := $(output_dir)/$(track_points_table).parquet
tracks_points_partitioned_dir := $(tracks_points_dir)/year=$(YEAR)/month=$(MONTH)
tracks_points_elevation_path := $(output_dir)/$(track_points_table).parquet/year=$(YEAR)/$(MONTH)_elevation.parquet
track_points_result := $(output_dir)/$(track_points_table).parquet/year=$(YEAR)/$(MONTH).parquet

track_parquet_file := $(tracks_dir)/$(SCHEMA)

# How many rows should be read in parallel
CHUNKS = 1000000
track_ids_file := $(output_dir)/$(SCHEMA)_$(CHUNKS)-ids.csv

# Configuration for grass gis
EPSG := 32633
grass_project := grass_db


# Configuration for GNU parallel
joblog := $(output_dir)/$(SCHEMA)-job.log


# This is the default pipeline
all: $(track_parquet_file) $(track_ids_file) extract-points generate-height

$(tracks_dir) $(tracks_points_partitioned_dir):
	@echo "create $@ directory"
	mkdir -p $@

# produce the parquet file from the postgres database
$(track_parquet_file): $(tracks_dir)
	@echo "extracting the table '$(tracks_table)' to parquet"
	ogr2ogr -progress -lco COMPRESSION=ZSTD -lco GEOMETRY_ENCODING=WKB -of Parquet $(track_parquet_file) PG:"host='$(PG_HOST)' user='$(PG_USER)' dbname='${PG_DBNAME}'" $(SCHEMA).$(tracks_table)

# split the parquet in chunks
$(track_ids_file):
	@echo "extacting ids by chunks"
	$(shell ./scripts/extract_ids.sh $(track_ids_file) $(track_parquet_file) $(CHUNKS))

generate-parquet: $(track_parquet_file)
	@echo "track parquet generated"

generate-ids: $(track_ids_file)
	@echo "force ids generated"

# GNU-Parallel chunks processing to extract points
extract-points: $(tracks_points_partitioned_dir)
	@echo "extracting points"
	cat $(track_ids_file) | parallel --colsep , --bar --joblog $(joblog) --resume --resume-failed ./scripts/extract_points.sh $(track_parquet_file) $(tracks_points_partitioned_dir) $(CHUNKS) {1} {2}

clean:
	rm -f $(joblog) $(results)
	rm -f $(tracks_points_partitioned_dir)/tmp_*

clean-output:
	rm -rf $(output_dir)

clean-grass:
	rm -rf $(grass_project) $(tracks_points_elevation_path)

# execute Grass to compute the elevation
$(tracks_points_elevation_path): clean-grass
	grass -c EPSG:$(EPSG) $(grass_project) -e --exec scripts/grass_bulk.sh $(ELEVATION_MODEL) $(tracks_points_partitioned_dir)/ month=$(MONTH) $(tracks_points_elevation_path)

generate-height: clean-grass $(tracks_points_elevation_path) clean-grass
	@echo "compute height of points"

grass:
	grass $(grass_project)

join-result:
	@echo "put together the height and the original position"
	$(shell ./scripts/join_points.sh $(tracks_points_partitioned_dir)/\* $(tracks_points_elevation_path) $(track_points_result))

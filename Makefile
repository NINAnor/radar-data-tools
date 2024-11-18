# Read variables from .env file (optionally)
-include .env
export

.PHONY: extract-points generate-ids generate-parquet clean clean-output generate-height

# Declare variables
# variables can be overridden while calling make

# DB to use
PG_DBNAME ?= utsira_max_1

output_dir := output/$(PG_DBNAME)

# Always read table with this name
tracks_table := track

# Extracted points will be put in this table
track_points_table := track_points

# Configuration for the schema based on the year/month
YEAR ?= 2019
MONTH ?= 10
SCHEMA = m$(YEAR)$(MONTH)


tracks_dir := $(output_dir)/$(tracks_table).parquet/year=$(YEAR)
tracks_points_dir := $(output_dir)/$(track_points_table).parquet
tracks_points_partitioned_dir := $(tracks_points_dir)/year=$(YEAR)/month=$(MONTH)
track_points_result := $(output_dir)/$(track_points_table).parquet/year=$(YEAR)/$(MONTH).parquet

track_parquet_file := $(tracks_dir)/$(SCHEMA)

# How many rows should be read in parallel
CHUNKS = 100000
track_ids_file := $(output_dir)/$(SCHEMA)_$(CHUNKS)-ids.csv

# Configuration for GNU parallel
joblog := $(output_dir)/$(SCHEMA)-job.log
elevation_joblog := $(output_dir)/$(SCHEMA)-elevation-job.log


# This is the default pipeline
all: $(elevation_joblog)

$(tracks_dir) $(tracks_points_partitioned_dir):
	@echo "create $@ directory"
	mkdir -p $@

# produce the parquet file from the postgres database
$(track_parquet_file): $(tracks_dir)
	@echo "extracting the table '$(tracks_table)' to parquet"
	OGR_PARQUET_ALLOW_ALL_DIMS=YES ogr2ogr -progress -lco COMPRESSION=ZSTD -lco GEOMETRY_ENCODING=WKB -of Parquet $(track_parquet_file) PG:"host='$(PG_HOST)' user='$(PG_USER)' dbname='${PG_DBNAME}'" $(SCHEMA).$(tracks_table)

# split the parquet in chunks
$(track_ids_file): $(track_parquet_file)
	@echo "extacting ids by chunks"
	./scripts/extract_ids.sh $(track_ids_file) $(track_parquet_file) $(CHUNKS)

# GNU-Parallel chunks processing to extract points
$(joblog): $(tracks_points_partitioned_dir) $(track_ids_file)
	@echo "points extraction..."
	parallel --colsep , --bar --joblog $(joblog) --resume --resume-failed ./scripts/extract_points.sh $(track_parquet_file) $(tracks_points_partitioned_dir) $(CHUNKS) {1} {2} :::: $(track_ids_file)

# GNU-Parallel chunks processing to get elevation model value for each pixel
$(elevation_joblog): $(joblog)
	@echo "computing height of points..."
	parallel --colsep , --bar --joblog $(elevation_joblog) --resume --resume-failed ./scripts/compute-coords.sh $(tracks_points_partitioned_dir)/_{1}.parquet $(ELEVATION_MODEL) $(tracks_points_partitioned_dir)/{1}.parquet :::: $(track_ids_file)

generate-parquet: $(track_parquet_file)
	@echo "track parquet generated"

generate-ids: $(track_ids_file)
	@echo "force ids generated"

extract-points: $(joblog)
	@echo "points extracted"

generate-height: $(elevation_joblog)
	@echo "computed height of points"

clean:
	rm -f $(tracks_points_partitioned_dir)/_*
	rm -f $(track_ids_file)

clean-output:
	rm -rf $(output_dir)
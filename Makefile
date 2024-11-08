ifneq (,$(wildcard ./.env))
    include .env
    export
endif

.PHONY: extract_points generate_ids

output_dir := output
tracks_table := track
track_points_table := track_points

tracks_dir := $(output_dir)/$(tracks_table)
tracks_points_dir := $(output_dir)/$(track_points_table)

YEAR = 2019
MONTH = 10
SCHEMA = m$(YEAR)$(MONTH)
track_parquet_file := $(tracks_dir)/$(SCHEMA).parquet
CHUNKS = 1000
track_ids_file := $(tracks_dir)/$(SCHEMA)-$(CHUNKS)ids.csv


joblog := $(tracks_points_dir)/job.log
results := $(tracks_points_dir)/results.csv


all: $(track_parquet_file) $(track_ids_file)

$(tracks_dir) $(tracks_points_dir):
	@echo "create $@ directory"
	mkdir -p $@

$(track_parquet_file): $(tracks_dir)
	@echo "extracting the table '$(tracks_table)' to parquet"
	ogr2ogr -progress -lco COMPRESSION=ZSTD -lco GEOMETRY_ENCODING=WKB -of Parquet $(track_parquet_file) $(PG_CONNECTION_STRING) $(SCHEMA).$(tracks_table)

$(track_ids_file):
	@echo "extacting ids by chunks"
	$(shell scripts/extract_ids.sh $(track_ids_file) $(track_parquet_file) $(CHUNKS))

generate_parquet: $(track_parquet_file)
	@echo "track parquet generated"

generate_ids: $(track_ids_file)
	@echo "force ids generated"

extract_points: $(tracks_points_dir)
	@echo "extracting points"
	cat $(track_ids_file) | parallel --colsep , --bar --joblog $(joblog) --resume --resume-failed --results $(results) scripts/extract_points.sh $(track_parquet_file) $(tracks_points_dir) $(CHUNKS) {1} {2}
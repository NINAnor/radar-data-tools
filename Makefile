ifneq (,$(wildcard ./.env))
    include .env
    export
endif

.PHONY: extract_points generate_ids generate_parquet clean

output_dir := output
tracks_table := track
track_points_table := track_points


YEAR = 2019
MONTH = 10
SCHEMA = m$(YEAR)$(MONTH)

tracks_dir := $(output_dir)/$(tracks_table).parquet/year=$(YEAR)/month=$(MONTH)
tracks_points_dir := $(output_dir)/$(track_points_table).parquet/year=$(YEAR)/month=$(MONTH)

track_parquet_file := $(tracks_dir)/$(SCHEMA)
CHUNKS = 1000000
track_ids_file := $(output_dir)/$(SCHEMA)_$(CHUNKS)-ids.csv


joblog := $(output_dir)/$(SCHEMA)-job.log
results := $(output_dir)/$(SCHEMA)-results.csv


all: $(track_parquet_file) $(track_ids_file) extract_points

$(tracks_dir) $(tracks_points_dir):
	@echo "create $@ directory"
	mkdir -p $@

$(track_parquet_file): $(tracks_dir)
	@echo "extracting the table '$(tracks_table)' to parquet"
	ogr2ogr -progress -lco COMPRESSION=ZSTD -lco GEOMETRY_ENCODING=WKB -of Parquet $(track_parquet_file) $(PG_CONNECTION_STRING) $(SCHEMA).$(tracks_table)

$(track_ids_file):
	@echo "extacting ids by chunks"
	$(shell ./scripts/extract_ids.sh $(track_ids_file) $(track_parquet_file) $(CHUNKS))

generate_parquet: $(track_parquet_file)
	@echo "track parquet generated"

generate_ids: $(track_ids_file)
	@echo "force ids generated"

extract_points: $(tracks_points_dir)
	@echo "extracting points"
	cat $(track_ids_file) | parallel --colsep , --bar --joblog $(joblog) --resume --resume-failed ./scripts/extract_points.sh $(track_parquet_file) $(tracks_points_dir) $(CHUNKS) {1} {2}

clean:
	rm -f $(joblog) $(results)
	rm -f $(tracks_points_dir)/tmp_*

clean-output:
	rm -rf $(output_dir)

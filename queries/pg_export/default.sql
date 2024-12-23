install postgres;
load postgres;

ATTACH '' AS pgdb (TYPE POSTGRES, READ_ONLY, SCHEMA '$schema');
COPY (SELECT * FROM pgdb."$table") TO '$dest_path/$table.parquet' (format parquet, overwrite true, CODEC zstd)

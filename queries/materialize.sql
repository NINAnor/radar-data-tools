
create or replace table radar as select * from read_parquet('$db_path/radar/*/*/*.parquet', hive_partitioning = true);
create or replace table species as select * from read_parquet('$db_path/species/*/*/*.parquet', hive_partitioning = true);
create or replace table classification as select * from read_parquet('$db_path/classification/*/*/*/*.parquet', hive_partitioning = true);
create or replace table weather as select * from read_parquet('$db_path/weather/*/*/*/*/*.parquet', hive_partitioning = true);
create or replace table observation as select * from read_parquet('$db_path/observation/*/*/*/*/*.parquet', hive_partitioning = true);
create or replace table track as select * from read_parquet('$db_path/track/*/*/*/*/*.parquet', hive_partitioning = true);
create or replace table track_point as select * from read_parquet('$db_path/track_point/*/*/*/*/*.parquet', hive_partitioning = true);
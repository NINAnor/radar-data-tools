# Query radar track points
The data is stored in partitioned parquet files, the recommended way of accessing the data is with `DuckDB`.
It's possible to use DuckDB for different languages, in particular [R](https://duckdb.org/docs/api/r.html) and [Python](https://duckdb.org/docs/api/python/overview), so this overview will focus on the SQL aspect rather than the wrapper language.

## How to read a parquet file

```sql
describe select * from read_parquet('track.parquet/year=2019/m201910');
select * from read_parquet('track_points.parquet/year=2019/month=10/*.parquet');
```

[Reference](https://duckdb.org/docs/guides/file_formats/parquet_import)


Example: read all the track points
```sql
select * from read_parquet('track_points.parquet/*/*/*.parquet', hive_partitioning = true) where "month" = 10;
```

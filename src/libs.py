from contextlib import contextmanager

import ibis
import marimo as mo

from settings import env

DUCKDB = env("DUCKDB", default=":memory:")


@contextmanager
def ibis_connection(instance=DUCKDB, memory_limit=2, read_only=False):
    connection = ibis.duckdb.connect(instance, read_only=read_only)
    connection.raw_sql(f"SET memory_limit = '{memory_limit}GB'")
    connection.raw_sql("install spatial")
    connection.raw_sql("LOAD spatial")

    try:
        yield connection
    finally:
        connection.disconnect()


def mprint(*args, **kwargs):
    mo.output.append(*args, **kwargs)


def extract_line_ids(track_input_path):
    with ibis_connection() as _con:
        _con.read_parquet(f"{track_input_path}.parquet", "track")
        _track = _con.table("track")
        _track.select("id").to_csv("temp.csv", header=False)
        return "temp.csv"


def extract_points_from_track(track_input_path, output_path, where=None, visual=False):
    with ibis_connection() as _con:
        query = f"""
            with points as (
                select id, unnest(st_dump(ST_Points(trajectory)), recursive := true)
                from "{track_input_path}.parquet"
                {f'where {where}' if where else ''}
            ), cleaned_points as (
                select
                    id,
                    ST_Force3DZ(geom, NULL) as geom,
                    ST_M(geom) as m,
                    unnest(path) as index
                from points
            )
            select
                cp.id,
                cp.index,
                cp.geom,
                cp.m,
                timestamp_start + interval (
                    list_extract(trj_time.trajectory_time, cp.index)
                ) seconds as timestamp,
                ST_Transform(cp.geom, 'EPSG:4326', 'EPSG:25835') as geom_25835,
                year(timestamp) AS year,
                month(timestamp) AS month
            from cleaned_points as cp
            join (
                select id, timestamp_start, trajectory_time
                from "{track_input_path}.parquet"
            ) as trj_time on trj_time.id = cp.id
            order by cp.id, cp.index
        """  # noqa: S608
        if visual:
            _con.read_parquet(f"{track_input_path}.parquet", "track")
            _track = _con.table("track")
            mprint(_track.sql(query).to_pandas())

        _con.raw_sql(f"""
            COPY ({query}) TO '{output_path}' (
                format parquet,
                partition_by (year, month, id),
                overwrite true, CODEC 'zstd')
        """)
        return query

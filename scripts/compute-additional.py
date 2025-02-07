#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "click",
#     "duckdb==1.2.0",
#     "pyproj",
#     "pyarrow>=19.0.0",
#     "numpy"
# ]
# ///

import click
import duckdb
import pyproj
from duckdb.typing import DOUBLE, FLOAT


def st_azimuth(lon, lat, lon2, lat2) -> float:
    return pyproj.Geod(ellps="WGS84").inv(lon, lat, lon2, lat2)[0]


@click.command()
@click.argument("parquet_source_path")
@click.argument("destination_path")
def process(parquet_source_path, destination_path):
    con = duckdb.connect()
    con.create_function(
        "ST_Azimuth", st_azimuth, [DOUBLE, DOUBLE, DOUBLE, DOUBLE], FLOAT, type="arrow"
    )

    con.sql(f"""
    INSTALL spatial;
    LOAD spatial;
            
    SET enable_progress_bar = true;
            
    copy (
        with bearing_points as (
            select 
                p1.id,
                p1.index_nr,
                case 
                    when p2.geom is null then null 
                    else (
                        st_distance_spheroid(p2.geom, p1.geom) / 
                        extract(epoch from (p2.timestamp - p1.timestamp))
                    )
                end as speed,
                case 
                    when p2.geom is null then null 
                    else ((ST_Azimuth(st_x(p1.geom), st_y(p1.geom), st_x(p2.geom), st_y(p2.geom)) + 360) % 360)
                end as bearing
            from read_parquet("{parquet_source_path}") as p1
            left join read_parquet("{parquet_source_path}") as p2 
            on 
                p1.id = p2.id and 
                p1.index_nr = p2.index_nr - 1
        )
        select 
            current.*,
            case 
                when prev.bearing is null then null 
                else 180 - abs(180 - abs(prev.bearing - current.bearing) % 360)
            end as tangle
        from bearing_points as current
        left join bearing_points as prev 
        on 
            current.id = prev.id and 
            current.index_nr = prev.index_nr + 1
    ) to "{destination_path}" (format parquet, overwrite true, CODEC zstd);
    """)


if __name__ == "__main__":
    process()

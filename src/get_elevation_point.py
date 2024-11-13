import logging
import traceback

import duckdb
import pyarrow as pa
import pyarrow.compute as pc
import rasterio
from duckdb.typing import DOUBLE, FLOAT


def safe_extractor(v):
    try:
        return v[0]
    except Exception as e:
        logging.error("error while extracting: ", v)
        logging.error(traceback.format_exc())
        raise e


def compute_elevation(elevation_model, epsg, track_points_path, output, band=1):
    conn = duckdb.connect()

    def get_elevation(xs, ys, zs):
        try:
            dataset = rasterio.open(elevation_model)
            positions = zip(
                xs.to_pylist(),
                ys.to_pylist(),
                strict=False,
            )
            result = pa.array(
                list(map(safe_extractor, dataset.sample(positions, indexes=band)))
            )
            dataset.close()
            result = pc.if_else(pc.is_nan(result), None, result)
            return pc.subtract(zs, result)
        except Exception as e:
            print(traceback.format_exc())
            raise e

    conn.create_function(
        "get_elevation",
        get_elevation,
        [DOUBLE, DOUBLE, DOUBLE],
        FLOAT,
        type="arrow",
        null_handling="SPECIAL",
    )

    res = conn.sql(f"""
        copy (
            with converted as (
                select *, st_transform(geom, 'EPSG:4326', '{epsg}', true) as converted_geom
                from read_parquet("{track_points_path}")
            ) select
                *,
                get_elevation(st_x(converted_geom), st_y(converted_geom), st_z(geom)) as elevation
            from converted
        ) to '{output}' (format parquet, overwrite true, CODEC 'zstd');
    """)  # noqa: E501, S608

    print(res)

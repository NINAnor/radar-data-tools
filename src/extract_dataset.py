import os
import pathlib
import subprocess


def run_extract_dataset(
    connection_string: str,
    output_directory: pathlib.Path,
    schema,
    layer_name,
    limit=None,
):
    env = os.environ.copy()
    env["OGR_PARQUET_ALLOW_ALL_DIMS"] = "YES"
    cmd = [  # noqa: S607
        "ogr2ogr",
        "-progress",
        "-lco",
        "COMPRESSION=ZSTD",
        "-lco",
        "GEOMETRY_ENCODING=WKB",
        limit and "-limit",
        limit and str(limit),
        "-of",
        "Parquet",
        pathlib.Path(output_directory) / layer_name / f"{schema}.parquet",
        connection_string,
        f"{schema}.{layer_name}",
    ]
    subprocess.run(  # noqa: S603
        list(
            filter(
                lambda x: x,
                cmd,
            )
        ),
        env=env,
    )

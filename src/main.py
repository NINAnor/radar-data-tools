import logging
import pathlib

import click

from cli import cli
from extract_dataset import run_extract_dataset
from gnuparallel import parallelize
from libs import extract_line_ids, extract_points_from_track
from settings import PG_CONN_STRING


@cli.command
@click.argument("layer", type=str)
@click.argument("output_directory", type=click.Path())
@click.option("--output_layer", default="track_points")
@click.option("--schema", type=str)
@click.option("--limit", type=int, default=None)
@click.option("--concurrency")
@click.option("--joblog")
@click.option("--results")
@click.option("--delay")
@click.option("--memfree")
@click.option("--retries")
@click.option("--load")
@click.option("-N", "--max-replace-args")
@click.option("--dry", is_flag=True)
@click.option("--resume", is_flag=True)
@click.option("--bar", is_flag=True)
@click.option("--progress", is_flag=True)
def full(layer, output_directory, schema, limit, output_layer, **kwargs):
    input_path = pathlib.Path(output_directory) / layer / f"{schema}"

    if not pathlib.Path(str(input_path) + ".parquet").exists():
        logging.debug("Exporting tracks")

        run_extract_dataset(
            PG_CONN_STRING, output_directory, schema, layer, limit=limit
        )
    else:
        logging.debug("Tracks already present, skipping...")
    output_dir = pathlib.Path(output_directory) / output_layer
    file_path = extract_line_ids(input_path)
    logging.debug("Parallel extraction of points")
    parallelize(
        ["radar_data_start", "track-points", input_path, output_dir],
        "::::",
        pathlib.Path(file_path),
        **kwargs,
    )


@cli.command()
@click.argument("layer", type=str)
@click.argument("output_directory", type=click.Path())
@click.option("--schema", type=str)
@click.option("--limit", type=int, default=None)
def extract_dataset(layer, output_directory, schema, limit):
    run_extract_dataset(PG_CONN_STRING, output_directory, schema, layer, limit=limit)


@cli.command
@click.argument("track_input_path", type=click.Path())
@click.argument("output_path", type=click.Path())
@click.argument("ids", nargs=-1, default=None)
def track_points(*args, ids=None, **kwargs):
    where = None
    if ids:
        where = f"id in {ids}"

    extract_points_from_track(*args, visual=False, where=where, **kwargs)


start = cli

if __name__ == "__main__":
    cli()

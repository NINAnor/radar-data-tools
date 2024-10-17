import logging
import pathlib
import subprocess

import click

from cli import cli
from extract_dataset import run_extract_dataset
from gnuparallel import parallelize
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
    subprocess.run(["scripts/extract_points.sh", input_path])  # noqa: S603, S607
    logging.debug("Parallel extraction of points")
    parallelize(
        ["scripts/extract_points.sh", input_path, output_dir],
        "::::",
        input_path + "-ids.csv",
        **kwargs,
    )


@cli.command()
@click.argument("layer", type=str)
@click.argument("output_directory", type=click.Path())
@click.option("--schema", type=str)
@click.option("--limit", type=int, default=None)
def extract_dataset(layer, output_directory, schema, limit):
    run_extract_dataset(PG_CONN_STRING, output_directory, schema, layer, limit=limit)


start = cli

if __name__ == "__main__":
    cli()

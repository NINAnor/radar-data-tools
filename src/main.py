import click

from cli import cli
from get_elevation_point import compute_elevation


@cli.command()
@click.argument("elevation_model", type=click.Path(exists=True))
@click.argument("epsg", type=click.STRING)
@click.argument("track_points_path", type=click.STRING)
@click.argument("output", type=click.STRING)
def generate_elevation_points(*args, **kwargs):
    compute_elevation(*args, **kwargs)


start = cli

if __name__ == "__main__":
    cli()

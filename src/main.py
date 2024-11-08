from cli import cli


@cli.command()
def test():
    pass


start = cli

if __name__ == "__main__":
    cli()

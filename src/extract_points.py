import marimo

__generated_with = "0.9.9"
app = marimo.App(width="medium")


@app.cell
def __():
    import pathlib

    import ibis
    import marimo as mo

    from libs import extract_points_from_track, mprint

    return extract_points_from_track, ibis, mo, mprint, pathlib


@app.cell
def __(extract_points_from_track, mprint):
    mprint(
        extract_points_from_track("output/track/m201910", "output/track_points", True)
    )
    return


if __name__ == "__main__":
    app.run()

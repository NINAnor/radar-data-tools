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

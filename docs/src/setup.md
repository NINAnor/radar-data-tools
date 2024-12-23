# Setup

**NOTE**: this is only required to generate the dataset, not to use it.

## Requirements
- Nix
- GNU/Linux

### Steps
1. Create a `.env` file in the folder, use `.env.example` as base
2. Create a `.pgpass` file in your `HOME`, add the credentials for the database

### How to use
```bash
nix-shell
task -a
```

### How does it work?
The software relies on different technologies to efficiently work, in particular to overcome issues of scalability the procedure works by partitioning the dataset on the fly and then parallelizing the operations.
- Nix, for creating a reproducible environment
- Taskfile, for describing a pipeline
- GNU Parallel, for running tasks on partitions in parallel
- GDAL, for efficiently compute the pixel value of the DEM
- DuckDB, for efficient data operations in-memory, postgres extraction
- Apache Parquet format, for storing intermediate and final results


A short description of the procedure follows:
- convert the `track` table in postgis (containing linestrings) to a local parquet file with DuckDB
- chunk the parquet in partitions of N elements in-memory
- using GNU Parallel a DuckDB query is run on each chunk, the query produces a row for each point in the linestring in the chunk and outputs to a parquet file
- each chunk is then sent to GDAL and the pixel value of the raster at the coordinates of each point is computed in parallel
- the final result is written to a new parquet file

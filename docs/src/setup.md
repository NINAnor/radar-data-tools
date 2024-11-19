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
make param1=value
```

#### Available parameters
from `.env`:
- `PG_HOST` hostname for postgresql connection
- `PG_USER` username for postgresql connection
- `ELEVATION_MODEL` path to the raster that contains the elevation model
 
from command line:
- `YEAR` year to process
- `MONTH` month to process
- `PG_DBNAME` database to connect to


## Tips
It's possible to use GDAL to merge on the fly different raster datasets
```bash
gdalbuildvrt dem.vrt /path/to/dir/*.tif
```

### How does it work?
The software relies on different technologies to efficiently work, in particular to overcome issues of scalability the procedure works by partitioning the dataset on the fly and then parallelizing the operations.
- Nix, for creating a reproducible environment
- Makefile, for describing a pipeline
- GNU Parallel, for running tasks on partitions in parallel
- GDAL, for extracting data from postgres and for efficiently compute the pixel value of the DEM
- DuckDB, for ultra efficient data operations in-memory
- Apache Parquet format, for storing intermediate and final results


A short description of the procedure follows:
- convert the `track` table in postgis (containing linestrings) to a local parquet file with GDAL
- chunk the parquet in partitions of N elements in-memory
- using GNU Parallel a DuckDB query is run on each chunk, the query produces a row for each point in the linestring in the chunk and outputs to a parquet file
- each chunk is then sent to GDAL and the pixel value of the raster at the coordinates of each point is computed in parallel
- the final result is written to a new parquet file

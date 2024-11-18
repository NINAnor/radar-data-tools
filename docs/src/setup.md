# Setup

## Requirements
- Nix
- GNU/Linux

### Steps
1. Create a `.env` file in the folder, use `.env.example` as base
2. Create a `.pgpass` file in your `HOME`, add the credentials for the database

### How to use
```bash
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

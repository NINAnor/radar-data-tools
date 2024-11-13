# Radar data scripts

## Setup
You need `nix` installed.

Copy the `.env.example` to a `.env` file and fill it.
Create a `.pgpass` file in your `HOME` and fill it with the credentials

**NOTE**: Ensure that the `ELEVATION_MODEL` contains all the vectors, otherwise you'll get a error with difference between DOUBLE and VARCHAR.

## Run
To execute the complete pipeline run:
```
nix-shell
make
```

You can use <TAB> to see available commands also.

Default parameters can be overloaded using arguments:
```
make YEAR=2020 MONTH=08
make PG_DBNAME=my_dbname
```


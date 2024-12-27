# Radar data scripts

## Setup
You need `nix` installed. 
Optionally you can install `direnv`, it will simplify the setup.

Copy the `.env.example` to a `.env` file and fill it.
Create a `.pgpass` file in your `HOME` and fill it with the credentials

## Usage
There are several commands available and documented:
```bash
> task -a
task: Available tasks for this project:
* queue:                                   Run a queue of tasks from a file
* db:manage:materialize:                   Creates a DuckDB database file importing all the parquet files
* dump:restore:all-from-config:            Restores tables from a config dump 
* dump:restore:all-from-data:              Restores the table weather, radar, observarion, classification, track according to the defined partition 
* dump:restore:classification:             Restores the table classification with a year partition 
* dump:restore:location-partitioned:       Restores a pg_dump table into a parquet file partitioned by location name
* dump:restore:month-partitioned:          Restores a pg_dump table into a parquet file partitioned by month
* dump:restore:observation:                Restores the table observation with a month partition 
* dump:restore:radar:                      Restores the table radar with a location partition 
* dump:restore:species:                    Restores the table species with a location partition 
* dump:restore:track:                      Restores the table track with a month partition 
* dump:restore:weather:                    Restores the table weather with a month partition 
* dump:restore:year-partitioned:           Restores a pg_dump table into a parquet file partitioned by year
* pg:export:                               Export a table to parquet 
* pg:export:all-from-config:               Export tables from the config schema 
* pg:export:all-from-data:                 Exports the table weather, radar, observarion, classification, track according to the defined partition 
* pg:export:classification:                Exports the table classification with a year partition 
* pg:export:location-partitioned:          Exports a postgres table into a parquet file partitioned by location name
* pg:export:month-partitioned:             Exports a postgres table into a parquet file partitioned by month
* pg:export:observation:                   Exports the table observation with a month partition 
* pg:export:radar:                         Exports the table radar with a location partition 
* pg:export:species:                       Exports the table species with a location partition 
* pg:export:track:                         Exports the table track with a month partition 
* pg:export:weather:                       Exports the table weather with a month partition 
* pg:export:year-partitioned:              Exports a postgres table into a parquet file partitioned by year
* track:generate:track-points:             Extract track points from track linestrings 
* track:generate:track-points-hogl:        Compute height over ground level of a track point parquet and saves them into a new parquet 
```

### Queue
The `queue` command allows to enqueue tasks in file, refer to `tasks.example` for an usage example, all the tasks will be run using `GNU parallel`.

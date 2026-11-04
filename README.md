![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)
![Apache Airflow](https://img.shields.io/badge/Apache%20Airflow-017CEE?logo=apacheairflow&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)
![pandas](https://img.shields.io/badge/pandas-150458?logo=pandas&logoColor=white)
![Polars](https://img.shields.io/badge/Polars-CD792C?logo=polars&logoColor=white)
![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?logoColor=black)

# European Energy Data Pipeline

A data engineering pipeline that collects, cleans and models public European energy data (electricity and gas), from API extraction all the way to Power BI dashboards.

Built as the final project of the **Data Engineer** program at Bruxelles Formation.


##  Reproducibility

This project was developed and tested on a specific local setup (Windows, SQL Server Express, Airflow in Docker). It **cannot be run** on another machine.
The code is published to showcase the architecture and the technical choices.



## Goal

Bring together data that is usually scattered across several sources into a single model.

## Data sources

| Source | Data | Frequency |
|---|---|---|
| [ENTSO-E Transparency Platform](https://transparency.entsoe.eu/) | Electricity generation per type, load, installed capacity, cross-border physical flows | Hourly / 15 min |
| [ENTSOG Transparency Platform](https://transparency.entsog.eu/) | Physical gas flows at interconnection points, point and operator reference data | Hourly / daily |
| [AGSI+ (GIE)](https://agsi.gie.eu/) | Gas storage per country | Daily |
| [Eurostat](https://ec.europa.eu/eurostat) | Population, median income, CO₂ emissions, heating and cooling degree days | Yearly |
| Country reference | Country codes, names, coordinates (latitude / longitude) | Static |

## Architecture

As shown on the image below, the Medallion Architecture has been used for this project. In a nutshell, data are extracted from the sources' REST APIs, ingested into a bronze database, transformed and cleaned in a silver database, and loaded as a dimensional model in a gold database, ready for analysis.

![Architecture](images/architecture.jpg)

At the start, more than 200 million rows were extracted, for a total size of 30 Go. After transformation, only 2.4 millions rows remained, because of the change in granularity. The lowest frequency of gas and electricity data retrieved was daily, so all other datas (15min and hourly) was aggregated to daily.
### Stack

| Role | Tool |
|---|---|
| Orchestration | Apache Airflow 3 (Docker Compose, LocalExecutor) |
| Extraction | Python, requests, pandas, Polars |
| Storage and transformation | SQL Server Express 2025 (T-SQL) |
| Visualisation | Power BI |

## Project structure

```
Project/
|──
|── config/                      # Config files for Airflow
|── docker-compose.yaml          # Configuration and organization of Docker 
|── dags/
│   ├── historical_dag.py        # Full historical load
│   ├── daily_dag.py             # Daily update
│   └── pipeline/                # All the scripts and functions that are called in the dags
│       ├── historical/
│       └── daily/
|── images/                      # Images
|── README.md
|── docker-compose.yaml          # Configuration and organization of Docker 
```

## Airflow pipelines

### Historical DAG

Loads the full period since 2021. Tasks are grouped into TaskGroups:

```
extract  >>  compact  >>  setupDB  >>  ingest  >>  silver
```

- **extract**: API downloads, one file per month and per source. Files that already exist are skipped, so the DAG can be restarted after a failure without downloading everything again.
- **compact**: converts the CSV files to Parquet.
- **setupDB**: creates the databases and the bronze tables.
- **ingest**: `BULK INSERT` into bronze.
- **silver**: runs the silver scripts **sequentially** (demo → gas → elec → env → date). Running them in parallel caused deadlocks on the same database.

### Daily DAG

- Scheduled `@daily`, without backfilling (`catchup=False`).
- Extracts a **rolling window** of the last few days rather than just yesterday, to pick up data that grid operators publish late or correct afterwards.
- Deletes that same window from bronze before reloading it, so re-running the DAG never creates duplicates.
- Fully rebuilds silver. Gold is made of views, so there is nothing to recompute.

## ⭐ Gold model

### Dimensions

| View | Content |
|---|---|
| `dim.date` | Calendar (day, month, year…) |
| `dim.country` | Country, name, latitude / longitude (for Azure Maps) |
| `dim.production_type` | Production types, with renewable / low-carbon flags |

### Facts

| View | Grain | Content |
|---|---|---|
| `fact.electricity_generation_daily` | day × country × type | Electricity generation (MWh) |
| `fact.electricity_load_daily` | day × country | Electricity load (MWh) |
| `fact.electricity_flow_daily` | day × exporting country × importing country | Physical electricity flows (MWh) |
| `fact.gas_flow_daily` | day × exporting country × importing country | Gas flow as declared by each side (MWh) |
| `fact.installed_capacity_year` | year × country × type | Installed capacity (MW) |
| `fact.country_year` | year × country | Population, CO₂ emissions, degree days |

The model uses **natural keys** (date, country code, production type) rather than surrogate IDs: it is easier to read, and views do not need generated keys.

## 🔍 Data quality

### Gas flows are declared twice

On ENTSOG, every cross-border flow is reported **by both transmission system operators**: the exporting country reports an *exit* and the importing country reports an *entry*. Both declarations are deliberately kept in `fact.gas_flow_daily`:

| date | export_country | import_country | value_declared_by_exporter | value_declared_by_importer |
|---|---|---|---|---|

Keeping both makes it possible to **measure the gap** between the declarations instead of hiding it.

### Example: France → Belgium, January 2024

- When both sides published complete data, the values agree within about 0.5%.
- The large gaps correspond to **incomplete days**: missing hours on one side, notably on some days on the GRTgaz side.
- Hourly and daily values published for the same point do not always match each other: this is an inconsistency in the source data, not in the pipeline.

### Other issues handled

- **Duplicate versions**: the same period can be published as *Provisional* and later as *Confirmed*. Silver keeps a single version (*Confirmed* first, then the most recent).
- **Domestic points**: transmission points between operators of the same country (e.g. DE–DE) are not international exchanges and are excluded.
- **Non-EU neighbours**: for Russia, Norway, Turkey or North Africa, only the European side reports the flow.
- **Non-cross-border points**: final consumption, storage, production, distribution and LNG terminals are kept separate from interconnections.
- **Validity periods**: the ENTSOG point reference data changes over time. Joins take the validity dates into account, and an empty validity date is treated as "always valid".

## 🚧 Limitations and possible improvements

- **Gas day**: gas is aggregated per UTC calendar day, whereas ENTSOG uses a gas day (6 am – 6 am, Brussels time). Daily totals can therefore differ slightly from those on the ENTSOG website.
- **Mixed gas data**: some values come from hourly series, others from daily series. A fully daily re-extraction would simplify the model.
- **LNG and storage**: extracted but not yet included in the gold model.
- **Reproducibility**: run SQL Server in a Docker container, parameterise the paths (environment variables) and add a database creation script.
- **Incremental loading**: silver is fully rebuilt on every run. This is fast at the current volume but would not scale.
- **Tests**: add automated checks (duplicates, missing values, gaps between mirror declarations).

## 👤 Author

**Mathias Petini** – [GitHub](https://github.com/mpetini1307)

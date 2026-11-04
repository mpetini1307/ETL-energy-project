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

Bring together energy data (gas and electricity) into a single model.
Additional data such as population, median income, GHG emissions and degree days was also included. 

In this project, this data was not analysed but only displayed. It was added to build a richer and more complex data model.

## Data sources

| Source | Data | Frequency |
|---|---|---|
| [ENTSO-E Transparency Platform](https://transparency.entsoe.eu/) | Electricity generation per type, load, installed capacity, physical flows | Hourly / 15 min |
| [ENTSOG Transparency Platform](https://transparency.entsog.eu/) | Physical gas flows at interconnection points, point and operator reference data | Hourly / daily |
| [AGSI+ (GIE)](https://agsi.gie.eu/) | Gas storage per country | Daily |
| [Eurostat](https://ec.europa.eu/eurostat) | Population, median income, gas emissions, heating and cooling degree days | Yearly |
| [Country reference](https://restcountries.com) | Country codes, names, coordinates (latitude, longitude) | Static |

## Architecture

As shown on the image below, the Medallion Architecture has been used for this project. In a nutshell, data are extracted from the sources' REST APIs, ingested into a bronze database, transformed and cleaned in a silver database, and loaded as a dimensional model in a gold database, ready for analysis.

![Architecture](images/architecture.jpg)

At the start, more than 200 million rows were extracted, for a total size of 30 GB. After transformation, only 2.4 millions rows remained, because of the change in granularity. The lowest frequency of gas and electricity data retrieved was daily, so all other datas (15min and hourly) was aggregated to daily.

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
```

## Airflow pipelines

Two pipelines were built. The first one is the **initial load**, which extracts all the historical datas for all the sources. The second one is the **incremental load** that runs every morning to download all the new and updated data. 

### Historical DAG


```
extract  >>  compact  >>  setupDB  >>  ingest  >>  transform >> load
```

- **extract**: API downloads, one file per month and per source. (+5 000 files)
- **compact**: compacts all CSV files of each source into a single file to facilitate ingestion in a SQL database.
- **setupDB**: creates the databases, the bronze and gold tables.
- **ingest**: `BULK INSERT` into bronze.
- **transform**: transforms and cleans the data (ex: normalized time period in daily).
- **load** : loads all the data in the Data Warehouse.

### Daily DAG

```
extract  >>  compact  >> ingest >> merge >> load >> update_watermark
```
- **extract**: API downloads, one file per month and per source. (+1 000 files)
- **compact**: compacts all CSV files of each source into a single file to facilitate ingestion in a SQL database.
- **ingest**: `BULK INSERT` into a new database called newBronze.
- **merge** : upsert the newBronze in the silver. Check if the row exists, if it exists : update the row, if not : add it.
- **load** : deletes the gold layer, recreates it and loads all the data in the Data Warehouse.
- **update_watermark** : keeps a mark when the update was run and what day was downloaded, so the next run knows where to start.


## Gold model

Here is an extremely schematic view of the Data Warehouse to highlight the main tables, the full model is shown at the end of the README. 
The gold layer is a **galaxy schema**. All fact tables are linked through the Date and the Country

![Gold model (simplified)](images/DWH.jpg)

## Visualisations

One the pipeline has run, the DWH can be explored in powerBI. Here is an example.

The upper chart shows the total energy production (MWh) in Belgium in 2025, which is entirely electricity. The lower chart shows the installed capacity (MW): solar is the largest installed capacity in Belgium, with a total of 10.7 GW. The slicers on the left filter both charts.
At the left can be shown all the filter to display the specific graph wanted. 

![Production](images/production_powerbi.jpg)

## Data Quality 

On ENTSOG (gas data), every gas flow is reported by both countries: the exporting country declares an exit and the importing country declares an entry. But sometimes, both declarations are not the same.
On the image below, two rows was taken showing the amount of gas exported from Belgium to France. Belgium declared an amount of 461 (GWh) exported and France an amount of 205 (GWh) imported, which gives a difference of 55.6%. The second shows the same with a difference of 25%.

As this problem occured very often, all the data were kept but makes the analysis not reliable.

![Data quality](images/data_quality.jpg)

## Appendix 
Full DWH from the model view of PowerBI
![Gold model (complex)](images/complex_DWH.jpg)

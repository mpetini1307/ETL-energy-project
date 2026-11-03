from airflow.sdk import DAG, task, TaskGroup
from datetime import date, timedelta
from pipeline.config import ENTSOE_FOLDERS
from pipeline.daily.extract.updated_entsoe import download_entsoe_folder
from pipeline.daily.extract.updated_entsog import download_operator_points, download_entsog_updates
from pipeline.daily.extract.updated_agsi import download_agsi
from pipeline.daily.compact.csv_to_parquet import compact_entsoe,compact_entsog,compact_agsi
from pipeline.daily.ingest.to_sql import ingest_entsog, ingest_agsi, ingest_entsoe_flow, ingest_entsoe_load, ingest_entsoe_generation, ingest_entsoe_installed_capacity
from pipeline.daily.extract.watermark import get_watermark, add_watermark


UPDATE_FROM = date(2026, 10, 20)   # date de départ des mises à jour, à changer à la main
UPDATE_FROM_DAY_BEDORE = date(2026, 10, 18)   # date de départ des mises à jour, à changer à la main

with DAG(
    dag_id="test_data",
    schedule=None,                 # lancé à la main
    catchup=False,
    max_active_runs=1,
    tags=["rawdata", "daily"],
):
        ########################
        #       EXTRACT        #
        ########################
        @task
        def update_watermark():
                add_watermark()
        ########################
        #       COMPACT        #
        ########################

        @task(task_id = "compact_entsoe") 
        def compact_entsoe_to_parquet():
                compact_entsoe(UPDATE_FROM)

        @task(task_id = "compact_entsog") 
        def compact_entsog_to_parquet():
                compact_entsog(UPDATE_FROM)

        @task(task_id = "compact_agsi") 
        def compact_agsi_to_parquet():
                compact_agsi(UPDATE_FROM_DAY_BEDORE)


########################
#        INGEST          #
########################
        @task
        def load_entsoe():
                ingest_entsoe_load(UPDATE_FROM)
                ingest_entsoe_generation(UPDATE_FROM)
                ingest_entsoe_installed_capacity(UPDATE_FROM)
                ingest_entsoe_flow(UPDATE_FROM)

        @task
        def load_entsog():
                ingest_entsog(UPDATE_FROM)

        @task
        def load_agsi():
                ingest_agsi(UPDATE_FROM_DAY_BEDORE)

##############################
#       FUNCTIONS CALL       #
##############################
        with TaskGroup("compact") as compact:
                compact_entsoe_to_parquet()
                compact_entsog_to_parquet()
                compact_agsi_to_parquet()

        with TaskGroup("ingest") as ingest:
                load_entsoe()
                load_entsog()
                load_agsi()



        compact >> ingest >> update_watermark()
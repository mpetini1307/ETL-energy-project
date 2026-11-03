from airflow.sdk import DAG, task, TaskGroup
from datetime import date, timedelta
from pipeline.config import ENTSOE_FOLDERS
from pipeline.daily.extract.updated_entsoe import download_entsoe_folder
from pipeline.daily.extract.updated_entsog import download_operator_points, download_entsog_updates
from pipeline.daily.extract.updated_agsi import download_agsi
from pipeline.daily.compact.csv_to_parquet import compact_entsoe,compact_entsog,compact_agsi
from pipeline.daily.ingest.to_sql import ingest_entsog, ingest_agsi, ingest_entsoe_flow, ingest_entsoe_load, ingest_entsoe_generation, ingest_entsoe_installed_capacity
from pipeline.daily.extract.watermark import get_watermark, add_watermark
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator


UPDATE_FROM = date(2026, 10, 10)   # date de départ des mises à jour, à changer à la main
UPDATE_FROM_DAY_BEDORE = date(2026, 10, 9)   # date de départ des mises à jour, à changer à la main

with DAG(
    dag_id="daily_data",
    schedule=None,                 # lancé à la main
    catchup=False,
    max_active_runs=1,
    tags=["rawdata", "daily"],
):
    ########################
    #       EXTRACT        #
    ########################
    def hier():
        return date.today() - timedelta(days=1)

    @task(pool="entsoe_data", task_id="entsoe_datas")
    def entsoe_datas(folder):
        download_entsoe_folder(folder, UPDATE_FROM)

    @task
    def entsog_operator_points():
        download_operator_points()

    @task
    def entsog_updates():
        download_entsog_updates(UPDATE_FROM)

    @task
    def agsi_updates():
        download_agsi(UPDATE_FROM_DAY_BEDORE)

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
#        INGEST        #
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

#####################
#       SQL         #
#####################
    def sql_task(task_id: str, file: str, conn_id: str):
        return SQLExecuteQueryOperator(task_id=task_id, conn_id=conn_id, sql=file,autocommit=True, split_statements=True,show_return_value_in_logs=True)


##############################
#       FUNCTIONS CALL       #
##############################

    with TaskGroup("extract") as extract:
        entsoe_datas.expand(folder=ENTSOE_FOLDERS)
        entsog_operator_points() >> entsog_updates()
        agsi_updates()

    with TaskGroup("compact") as compact:
        compact_entsoe_to_parquet()
        compact_entsog_to_parquet()
        compact_agsi_to_parquet()

    with TaskGroup("ingest") as ingest:
        load_entsoe()
        load_entsog()
        load_agsi()

    with TaskGroup("merge") as merge:
        sql_task("merge_elec_capacity","pipeline/daily/merge/MERGE_elec_capacity.sql","mssql_bronze_update")
        sql_task("merge_elec_flow","pipeline/daily/merge/MERGE_elec_flow.sql","mssql_bronze_update")
        sql_task("merge_elec_generation","pipeline/daily/merge/MERGE_elec_generation.sql","mssql_bronze_update")
        sql_task("merge_elec_load","pipeline/daily/merge/MERGE_elec_load.sql","mssql_bronze_update")
        sql_task("merge_gas_flow","pipeline/daily/merge/MERGE_gas_flow.sql","mssql_bronze_update")
        sql_task("merge_gas_storage","pipeline/daily/merge/MERGE_gas_storage.sql","mssql_bronze_update")


    extract >> compact >> ingest >> merge >> update_watermark()
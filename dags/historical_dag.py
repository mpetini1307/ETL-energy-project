from airflow.sdk import DAG, task, TaskGroup
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

from pipeline.config import ENTSOG_YEARS, ENTSOE_FOLDERS, EUROSTAT_DB_TO_DL
from pipeline.historical.extract.entsoe import download_folder
from pipeline.historical.extract.entsog import download_year, download_operator_points
from pipeline.historical.extract.eurostat_db import download_eurostat
from pipeline.historical.extract.agsi import download_agsi
from pipeline.historical.extract.countries import download_countries
from pipeline.historical.compact.csv_to_parquet import compact_entsoe,compact_entsog,compact_agsi

with DAG(
    dag_id="historical_data",
    schedule=None,                 # lancé à la main
    catchup=False,
    max_active_runs=1,
    tags=["rawdata", "historical"],
):
########################
#       EXTRACT        #
########################
    @task(pool="entsoe_data",task_id = "enstoe_datas")
    def entsoe_datas(folder: str):
        download_folder(folder)

    @task(task_id = "enstog_operator_points")
    def entsog_operator_points():
        download_operator_points()

    @task(pool="entsog_data",task_id = "enstog_datas")
    def entsog_datas(year):
        download_year(year)


    @task(task_id = "eurostat_datas")
    def eurostat_data(database):
        download_eurostat(database)


    @task(task_id = "agsi_datas")
    def agsi_datas():
        download_agsi()


    @task(task_id = "country_datas")
    def countries_datas():
        download_countries()

########################
#       COMPACT        #
########################

    @task(task_id = "compact_entsoe") 
    def compact_entsoe_to_parquet():
        compact_entsoe()

    @task(task_id = "compact_entsog") 
    def compact_entsog_to_parquet():
        compact_entsog()

    @task(task_id = "compact_agsi") 
    def compact_agsi_to_parquet():
        compact_agsi()


#####################
#       SQL         #
#####################
    def sql_task(task_id: str, file: str, conn_id: str):
        return SQLExecuteQueryOperator(
            task_id=task_id, conn_id=conn_id, sql=file,
            autocommit=True, split_statements=True)

##############################
#       FUNCTIONS CALL       #
##############################

    with TaskGroup("extract") as extract:
        entsoe_datas.expand(folder = ENTSOE_FOLDERS)
        entsog_operator_points() >> entsog_datas.expand(year = ENTSOG_YEARS)
        eurostat_data.expand(database = EUROSTAT_DB_TO_DL)
        agsi_datas()
        countries_datas()

    with TaskGroup("compact") as compact:
        compact_entsoe_to_parquet()
        compact_entsog_to_parquet()
        compact_agsi_to_parquet()

    with TaskGroup("setupDB") as setupDB:
        sql_task("create_databases","pipeline/setup_db.sql","mssql_master")
        sql_task("create_bronze_tables","pipeline/historical/ingest/CREATE_bronze_tables.sql","mssql_bronze")
        sql_task("create_gold_tables","pipeline/CREATE_TABLE_gold.sql","mssql_gold")


    with TaskGroup("ingest") as ingest:
        sql_task("bulk_insert_gas","pipeline/historical/ingest/BULK_INSERT_gas.sql","mssql_bronze")
        sql_task("bulk_insert_elec","pipeline/historical/ingest/BULK_INSERT_elec.sql","mssql_bronze")
        sql_task("bulk_insert_demo","pipeline/historical/ingest/BULK_INSERT_demo.sql","mssql_bronze")
        sql_task("bulk_insert_env","pipeline/historical/ingest/BULK_INSERT_env.sql","mssql_bronze")

    with TaskGroup("transform") as transform:
        demo = sql_task("bronze_to_silver_demo","pipeline/historical/transform/TRANSFORM_demo_to_silver.sql","mssql_bronze")
        gas = sql_task("bronze_to_silver_gas","pipeline/historical/transform/TRANSFORM_gas_to_silver.sql","mssql_bronze")
        elec = sql_task("bronze_to_silver_elec","pipeline/historical/transform/TRANSFORM_elec_to_silver.sql","mssql_bronze")
        env = sql_task("bronze_to_silver_env","pipeline/historical/transform/TRANSFORM_env_to_silver.sql","mssql_bronze")
        date = sql_task("bronze_to_silver_date","pipeline/historical/transform/TRANSFORM_date_to_silver.sql","mssql_bronze")

        demo >> [gas,elec,env,date]

    with TaskGroup("load") as load:
        dim_country = sql_task("silver_to_gold_country","pipeline/historical/load/Dim_Country(1).sql","mssql_silver")
        dim_date = sql_task("silver_to_gold_date","pipeline/historical/load/Dim_Date(2).sql","mssql_silver")
        dim_energy = sql_task("silver_to_gold_energy_type","pipeline/historical/load/Dim_Energy_Type(4).sql","mssql_silver")
        fact_capacity = sql_task("silver_to_gold_capacity","pipeline/historical/load/FACT_Capacity(2).sql","mssql_silver")
        fact_consumption = sql_task("silver_to_gold_consumption","pipeline/historical/load/FACT_Consumption(1).sql","mssql_silver")
        fact_flow = sql_task("silver_to_gold_flow","pipeline/historical/load/FACT_Flow(1).sql","mssql_silver")
        fact_production = sql_task("silver_to_gold_production","pipeline/historical/load/FACT_Production(1).sql","mssql_silver")
        fact_storage =sql_task("silver_to_gold_storage","pipeline/historical/load/FACT_Storage(1).sql","mssql_silver")
        fact_population = sql_task("silver_to_gold_population","pipeline/historical/load/FACT_population(1).sql","mssql_silver")
        fact_degree_days = sql_task("silver_to_gold_degree_days","pipeline/historical/load/FACT_Degree_Days(1).sql","mssql_silver")
        fact_ghg = sql_task("silver_to_gold_ghg_emissions","pipeline/historical/load/FACT_Ghg_emissions(1).sql","mssql_silver")
        fact_median_income = sql_task("silver_to_gold_median_income","pipeline/historical/load/FACT_Median_Income(1).sql","mssql_silver")
                    
        dim_country >> dim_date >> dim_energy >> [fact_capacity,fact_consumption,fact_flow,fact_production,fact_storage,fact_storage,fact_population,fact_degree_days,fact_ghg,fact_median_income]
            
        
    


    extract >> compact >> setupDB >> ingest >> transform >> load
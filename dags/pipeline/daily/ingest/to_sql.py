import logging
import pandas as pd
from airflow.providers.microsoft.mssql.hooks.mssql import MsSqlHook

from pipeline.config import COMPACT_DIR_UPDATE, ENTSOE_FOLDERS

log = logging.getLogger(__name__)

CONN_ID = "mssql_bronze_update"

WINDOWS_COMPACT_DIR = r"C:\Users\PC\Documents\Projets\TFF\data\updated_raw\compacted"

def bulk_insert(path, schema, table):
    if not path.exists():
        log.info("No file updated", path)
        return
 
    ###Même chemin relatif, mais vu depuis Windows par SQL Server
    relative = path.relative_to(COMPACT_DIR_UPDATE)
    windows_path = WINDOWS_COMPACT_DIR + "\\" + str(relative).replace("/", "\\")
 
    MsSqlHook(mssql_conn_id=CONN_ID).run(f"""
        TRUNCATE TABLE {schema}.{table};
        BULK INSERT {schema}.{table}
        FROM '{windows_path}'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
    """)
    log.info("%s chargé dans %s.%s", windows_path, schema, table)

def ingest_entsog(day):
    bulk_insert(COMPACT_DIR_UPDATE / "entsog" / day.isoformat() / f"entsog_{day.isoformat()}.csv", "gas", "flow")


def ingest_agsi(day):
    bulk_insert(COMPACT_DIR_UPDATE / "agsi" / day.isoformat() / "agsi.csv", "gas", "storage")


def ingest_entsoe_flow(day):
    bulk_insert(COMPACT_DIR_UPDATE / "entsoe" / day.isoformat() / f"entsoe_PhysicalFlows_12.1.G_r3.csv", "elec", "flow")

def ingest_entsoe_load(day):
    bulk_insert(COMPACT_DIR_UPDATE / "entsoe" / day.isoformat() / f"entsoe_ActualTotalLoad_6.1.A_r3.csv", "elec", "actual_total_load")

def ingest_entsoe_generation(day):
    bulk_insert(COMPACT_DIR_UPDATE / "entsoe" / day.isoformat() / f"entsoe_AggregatedGenerationPerType_16.1.B_C_r3.csv", "elec", "generation")

def ingest_entsoe_installed_capacity(day):
    bulk_insert(COMPACT_DIR_UPDATE / "entsoe" / day.isoformat() / f"entsoe_InstalledGenerationCapacityAggregated_14.1.A_r3.csv", "elec", "installed_capacity")
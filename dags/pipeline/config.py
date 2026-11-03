import os
from pathlib import Path


PROJECT_DIR = Path(__file__).resolve().parents[2]
DATA_DIR = Path(os.environ.get("DATA_DIR", PROJECT_DIR / "data" / "raw"))
DATA_DIR_UPDATE = Path(os.environ.get("DATA_DIR", PROJECT_DIR / "data" / "updated_raw"))
COMPACT_DIR = DATA_DIR / "compacted"
COMPACT_DIR_UPDATE = DATA_DIR_UPDATE / "compacted"

# ============================================================
# Info for enstoe
# ============================================================

ENTSOE_USER = os.environ.get("ENTSOE_USER")
ENTSOE_PWD = os.environ.get("ENTSOE_PWD")

ENTSOE_KEYCLOAK_URL = "https://keycloak.tp.entsoe.eu/realms/tp/protocol/openid-connect/token"
ENTSOE_FOLDER_URL = "https://fms.tp.entsoe.eu/listFolder"
ENTSOE_DOWNLOAD_URL = "https://fms.tp.entsoe.eu/downloadFileContent"

ENTSOE_FOLDERS = [
    "ActualTotalLoad_6.1.A_r3",
    "AggregatedGenerationPerType_16.1.B_C_r3",
    "InstalledGenerationCapacityAggregated_14.1.A_r3",
    "PhysicalFlows_12.1.G_r3",
]


# ============================================================
# Info for enstog
# ============================================================

ENTSOG_OPERATORS_URL = "https://transparency.entsog.eu/api/v1/operatorpointdirections"
ENTSOG_DOWNLOAD_URL = "https://transparency.entsog.eu/api/v1/operationaldatas"

ENTSOG_YEARS = [2021,2022,2023,2024,2025,2026]


# ============================================================
# Info for agsi
# ============================================================

AGSI_API_KEY = os.getenv("AGSI_API_KEY")
AGSI_URL = "https://agsi.gie.eu/api"
AGSI_COUNTRY_URL = "https://agsi.gie.eu/api/about?show=listing"


# ============================================================
# Info for eurostat
# ============================================================


EUROSTAT_DB_TO_DL = [
    "sdg_13_10",
    "ilc_di03",
    "tps00001"
    ,"nrg_chdd_a"
]


# ============================================================
# Info for country_info
# ============================================================

COUNTRY_URL = "https://api.restcountries.com/countries/v5"
COUNTRY_API_KEY = os.getenv("COUNTRY_API_KEY")

import json
import logging
import time
import pandas as pd
import requests
import os 
from datetime import date, timedelta
from pipeline.config import (
    ENTSOE_DOWNLOAD_URL,
    ENTSOE_PWD,
    ENTSOE_USER,
    ENTSOE_FOLDER_URL,
    ENTSOE_KEYCLOAK_URL,
    DATA_DIR,
    DATA_DIR_UPDATE
)

log = logging.getLogger(__name__)

# ============================================================
# Gestion du token : rafraîchi automatiquement avant expiration   <--- créer par IA
# ============================================================

TOKEN_DUREE_MAX = 8 * 60  # rafraîchit après 8 min, avant l'expiration à 10 min

_token_cache = {"access_token": None, "obtenu_a": 0.0}

def obtenir_token() -> str:
    """Demande un nouveau token à Keycloak."""
    if not ENTSOE_USER or not ENTSOE_PWD:
        raise RuntimeError("ENTSOE_USER et ENTSOE_PWD doivent être définis dans le .env")

    resp = requests.post(
        ENTSOE_KEYCLOAK_URL,
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        data={
            "client_id": "tp-fms-public",
            "grant_type": "password",
            "username": ENTSOE_USER,
            "password": ENTSOE_PWD,
        },
        timeout=30,
    )
    resp.raise_for_status()
    return resp.json()["access_token"]


def get_headers() -> dict:
    """Renvoie les en-têtes HTTP avec un token valide (rafraîchi si besoin)."""
    maintenant = time.time()
    if _token_cache["access_token"] is None or maintenant - _token_cache["obtenu_a"] > TOKEN_DUREE_MAX:
        _token_cache["access_token"] = obtenir_token()
        _token_cache["obtenu_a"] = maintenant
    return {
        "Authorization": f"Bearer {_token_cache['access_token']}",
        "Content-Type": "application/json",
        "Accept": "*/*",
    }


# ============================================================
# jusqu'ici   <--- créer par IA
# ============================================================
"""Find all the files in a folder entsoe."""
def list_files(folder_name: str) -> list[str]:
    files = []
    data_info = json.dumps({
            "path": f"/TP_export/{folder_name}/",
            "pageInfo": {"pageIndex": 0, "pageSize": 5000},
        })
    resp = requests.post(ENTSOE_FOLDER_URL, headers=get_headers(), data=data_info)

    files = resp.json()["contentItemList"]

    log.info("%s : %d fichiers trouvés", folder_name, len(files))
    print(files)
    return files

"""Download a single file in a folder"""
def download_file(folder_name: str, file_name: str, update_day):
    path_folder = DATA_DIR_UPDATE / "entsoe" / f'{update_day}' / folder_name 
    if not os.path.exists(path_folder) :
            os.makedirs(path_folder)

    path_file_writing = path_folder / f"updated_{file_name}"
    debut = time.perf_counter()

    data_info = json.dumps({
            "folder": f"/TP_export/{folder_name}",
            "filename": file_name,
            "topLevelFolder": "TP_export",
            "downloadAsZip": False,
        })
    
    try :
        resp_dl =  requests.post(ENTSOE_DOWNLOAD_URL, headers=get_headers(),data=data_info)

    ###Si y'a une erreur non identifiée ça retourne les infos (ge)
    except requests.exceptions.RequestException as e :
        return {"folder": folder_name, "file": file_name, "status": "error", "message": str(e)}

    ###Si le site renvoie une code d'erreur (genre timeout)
    if resp_dl.status_code != 200:
            return {"folder": folder_name, "file": file_name, "status": "error", "message": resp_dl.text}
    with open(path_file_writing, "wb") as file:  # écrase le fichier s'il existe déjà
        file.write(resp_dl.content)

    duration = time.perf_counter() - debut

    file_size = os.path.getsize(path_file_writing) / (1024*1024)
    lines = resp_dl.content.count(b"\n")
    log.info("%s/%s : %.0f Mo en %.1f s", folder_name, file_name, file_size, duration)

    return {
        "status" : "ok",
        "folder": folder_name,
        "file": file_name,
        "size(Mo)": file_size,
        "time(s)": duration,
        "lines": lines
    }

"""Enter a folder of entso and it will dl each file in it"""
def download_entsoe_folder(folder,update_day) -> None:
    errors = []
    metadata = []
    for file in list_files(folder):

        ###Date de dernière mise à jour du fichier, en heure belge
        last_update = pd.to_datetime(file["lastUpdatedTimestamp"], utc=True).tz_convert("Europe/Brussels").date()

        ###On ne télécharge que les fichiers mis à jour aujourd'hui
        if last_update != update_day:
            continue

        result = download_file(folder, file["name"],update_day)
        if result == None: continue
        if result["status"] == "error":
            errors.append(result)
        else : metadata.append(result)

    path_metadata = DATA_DIR_UPDATE / "entsoe" / f'{update_day}'    / "metadata" 
    if not os.path.exists(path_metadata) : os.makedirs(path_metadata)
    path_errors = DATA_DIR_UPDATE / "entsoe" / f'{update_day}'    / "errors"
    if not os.path.exists(path_errors) :
                    os.makedirs(path_errors)

    pd.DataFrame(errors).to_csv(path_errors / f"errors_{folder}.csv", index=False)
    pd.DataFrame(metadata).to_csv(path_metadata/ f"metadata_{folder}.csv", index=False)
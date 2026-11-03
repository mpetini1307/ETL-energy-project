import logging
import time
import pandas as pd
import requests
import os
from datetime import datetime, date, timedelta

from pipeline.config import (
    ENTSOG_DOWNLOAD_URL,
    ENTSOG_OPERATORS_URL,
    DATA_DIR,
    DATA_DIR_UPDATE
)

log = logging.getLogger(__name__)

DATE_FROM = "2026-01-01"          # début de la période interrogée (borne le temps de calcul côté ENTSOG)
PAUSE_S = 0.5                     # pause entre deux appels pour ménager l'API


"""Download each operators and directions between 2 points (référentiel rechargé entièrement à chaque run)"""
def download_operator_points():

    path_folder = DATA_DIR / "entsog" / "operator_points"
    if not os.path.exists(path_folder):
        os.makedirs(path_folder)

    path_file_writing = path_folder / "all_operator_points.csv"

    params = {
        "limit": -1,
        "hasData": 1,
    }

    resp = requests.get(ENTSOG_OPERATORS_URL, params=params, timeout=60)
    resp.raise_for_status()
    df = pd.DataFrame(resp.json()["operatorpointdirections"])
    df["pointId"] = (df["operatorKey"] + df["pointKey"] + df["directionKey"]).str.lower()
    df.to_csv(path_file_writing, index=False)

    log.info("%d operator points ", len(df))


def download_point(update_day, pointId, periodType):
    date_to = date.today().isoformat()

    parameters = {
        "indicator": "Physical Flow",
        "pointDirection": pointId,
        "from": DATE_FROM,
        "to": date_to,
        "lastUpdateDateTime": update_day.isoformat(),
        "periodType": periodType,
        "timeZone": "CET",
        "limit": -1,
    }
    dt = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    path_day = DATA_DIR_UPDATE / "entsog" / update_day.isoformat()
    if not os.path.exists(path_day):
        os.makedirs(path_day)
    file = path_day / f"updated_{pointId}.csv"
    if file.exists():
        print("already downloaded")
        return None

    start = time.perf_counter()

    ### Fais un request du site entsog
    try:
        resp = requests.get(ENTSOG_DOWNLOAD_URL, params=parameters, timeout=60)

    ###Si y'a une erreur non identifiée ça retourne les infos
    except requests.exceptions.RequestException as e:
        return {"dt": dt, "update_day": update_day.isoformat(), "point": pointId, "status": "error", "code": "NIerror", "message": str(e)[0:100]}

    ###Aucune ligne mise à jour ce jour-là pour ce point : ce n'est PAS une erreur en update
    if resp.status_code == 404:
        return {"dt": dt, "update_day": update_day.isoformat(), "point": pointId, "status": "nodata", "code": "nodata", "message": "Aucune mise à jour"}

    ###Si le site renvoie un code d'erreur (timeout 504, etc.)
    if resp.status_code != 200:
        return {"dt": dt, "update_day": update_day.isoformat(), "point": pointId, "status": "error", "code": "weberror", "message": resp.text[0:100]}

    df = pd.DataFrame(resp.json()["operationaldatas"])

    if df.shape[1] != 35:
        return {"dt": dt, "update_day": update_day.isoformat(), "point": pointId, "status": "error", "code": "col", "message": f"{df.shape[1]} colonnes au lieu de 35"}

    df.to_csv(file, index=False)

    duration = time.perf_counter() - start
    size_mo = os.path.getsize(file) / (1024 * 1024)

    log.info("%s %s : %d lignes, %.2f Mo, %.1f s", pointId, update_day, len(df), size_mo, duration)

    return {"dt": datetime.now().strftime("%Y-%m-%d %H:%M:%S"), "status": "ok", "update_day": update_day.isoformat(),
            "point": pointId, "lines": len(df), "size(Mo)": size_mo, "duration(s)": duration}


"""Download every point for one update day (hour first, day if no hourly data)"""
def download_update_day(update_day):
    POINTS_FILE = DATA_DIR / "entsog" / "operator_points" / "all_operator_points.csv"
    points_id = pd.read_csv(POINTS_FILE)["pointId"].drop_duplicates().tolist()
    metadata = []
    errors = []

    for point in points_id:
        result = download_point(update_day, point, "hour")
        time.sleep(PAUSE_S)

        ###Déjà dl
        if result is None:
            continue

        ###Pas de données horaires mises à jour : on tente en journalier
        if result["status"] == "nodata":
            result = download_point(update_day, point, "day")
            time.sleep(PAUSE_S)
            if result is None or result["status"] == "nodata":
                continue

        if result["status"] == "error":
            log.warning("%s %s : Error, %s", point, update_day, result["code"])
            errors.append(result)
        else:
            metadata.append(result)

    path_metadata = DATA_DIR / "entsog" / "metadata" / "updates"
    if not os.path.exists(path_metadata):
        os.makedirs(path_metadata)

    errors_dir = DATA_DIR / "entsog" / "errors" / "updates"
    if not os.path.exists(errors_dir):
        os.makedirs(errors_dir)

    pd.DataFrame(metadata).to_csv(path_metadata / f"metadata_{update_day.isoformat()}.csv", index=False)
    pd.DataFrame(errors).to_csv(errors_dir / f"errors_{update_day.isoformat()}.csv", index=False)

    return errors


"""Loop over each day since the watermark (included) up to today"""
def download_entsog_updates(watermark: date):
    all_errors = []
    d = watermark                                   # on repart du jour du watermark (inclus) pour ne rien rater
    while d <= date.today():
        log.info("Mises à jour ENTSOG du %s", d)
        all_errors.extend(download_update_day(d))
        d += timedelta(days=1)

    if all_errors:
        raise RuntimeError(f"{len(all_errors)} erreurs pendant l'update ENTSOG, voir le dossier errors/updates")
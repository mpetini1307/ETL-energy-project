import json
import logging
import time
import pandas as pd
import requests
import os 
from datetime import datetime

from pipeline.config import (
    ENTSOG_DOWNLOAD_URL,
    ENTSOG_OPERATORS_URL,
    ENTSOG_YEARS,
    DATA_DIR,
)

log = logging.getLogger(__name__)


"""Download each operators and directions between 2 points, then retrieve all the countries in it because we need them to partition our datas downloading"""
def download_operator_points():

    path_folder = DATA_DIR / "entsog" / "operator_points"
    if not os.path.exists(path_folder) :
            os.makedirs(path_folder)
    
    path_file_writing = path_folder / "all_operator_points.csv"
    
    params = {
    "limit": -1,
    "hasData": 1,
    }

    resp = requests.get(ENTSOG_OPERATORS_URL, params=params)
    df = pd.DataFrame(resp.json()["operatorpointdirections"])              ###On enleve les operators qui ne sont plus valides 
    df["pointId"] = (df["operatorKey"] + df["pointKey"] + df["directionKey"]).str.lower()                                    ###Need this info to find the pointId of a connector
    df.to_csv(path_file_writing, index=False)

    log.info("%d operator points ", len(df))


def download_point(year, pointId,periodType):
    from_date = f"{year}-01-01"
    if year == datetime.now().year:
        to_date = f"{year}-10-10"
    else : 
        to_date = f"{year}-12-31"

    parameters = {
    "indicator": "Physical Flow",
    "pointDirection": pointId,
    "from": from_date,
    "to": to_date,
    "periodType": f"{periodType}",
    "timezone": "CET",
    "limit": -1,
    }
    dt = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    path_year = DATA_DIR / "entsog" / str(year)
    if not os.path.exists(path_year) :
                os.makedirs(path_year)
    file = path_year / f"{pointId}.csv"
    if file.exists(): 
        print("already downloaded")
        return None 
    
    start = time.perf_counter()

    ### Fais un request du site entsog
    try :
        resp = requests.get(ENTSOG_DOWNLOAD_URL, params=parameters)

    ###Si y'a une erreur non identifiée ça retourne les infos (ge)
    except requests.exceptions.RequestException as e :
        return {"dt":dt,"year": year, "point": pointId, "status": "error", "code": "NIerror","message": str(e)[0:100]}

    ###SI Aucune data
    if resp.status_code == 404: 
        return {"dt":dt,"year": year, "point": pointId, "status": "error", "code": "nodata", "message": "Aucune Data"}

    ###Si le site renvoie une code d'erreur (genre timeout)
    if resp.status_code != 200:
         return {"dt":dt,"year": year, "point": pointId, "status": "error","code": "weberror", "message": resp.text[0:100]}

    
    
    df = pd.DataFrame(resp.json()["operationaldatas"])

    if df.shape[1] != 35:
        return {"dt":dt,"year": year, "point": pointId, "status": "error", "code": "col", "message": f"{df.shape[1]} colonnes au lieu de 35"}

    df.to_csv(file, index=False)

    duration = time.perf_counter() - start
    size_mo = os.path.getsize(file) / (1024*1024)

    log.info("%s %d : %d lignes, %.2f Mo, %.1f s", pointId, year, len(df),size_mo, duration)

    return {"dt":datetime.now().strftime("%Y-%m-%d %H:%M:%S"),"status":"ok","annee": year, "point": pointId, "lines": len(df),
                        "size(Mo)": size_mo, "duration(s)": duration}




def download_year(year):
    POINTS_FILE = DATA_DIR / "entsog" / "operator_points"  / "all_operator_points.csv"
    points_id = pd.read_csv(POINTS_FILE)["pointId"].drop_duplicates().tolist()
    metadata = []
    errors = []
    for point in points_id:
        result = download_point(year,point,"hour")
        ###Déjà dl
        if result is None : 
            continue
        ###metadata version error
        if result["status"] == "error":
            if result["code"] == "nodata":
                result = download_point(year,point,"day")

                if result["status"] == "error":
                    log.warning("%s %d : %s", point, year, f"Error, {result["code"]}")
                    errors.append(result)
                else: metadata.append(result)
        else:
            metadata.append(result)
    path_metadata = DATA_DIR / "entsog" / "metadata" 
    if not os.path.exists(path_metadata) : os.makedirs(path_metadata)

    errors_dir = DATA_DIR / "entsog" / "errors"
    errors_file = errors_dir / f"errors_{year}.csv"
    if not os.path.exists(errors_dir) : os.makedirs(errors_dir)

    if os.path.exists(errors_file):
        path_still_errors = errors_dir / "still_errors"
        path_resolved_errors = errors_dir / "resolved_errors"
        if not os.path.exists(path_still_errors) :
            os.makedirs(path_still_errors)

        if not os.path.exists(path_resolved_errors) :
                    os.makedirs(path_resolved_errors)
        set_old_errors = set(pd.read_csv(errors_file)["point"])  ###permet de récupérer un liste en forme "set" afin de comparer
        set_new_errors = {e["point"] for e in errors}

        point_retrieved = set_old_errors-set_new_errors
        still_errors = set_new_errors&set_old_errors

        resolved_pt = pd.DataFrame(point_retrieved, columns=["point"])
        still_errors_pt = pd.DataFrame(still_errors, columns=["point"])

        resolved_pt.to_csv(path_resolved_errors / f"resolved_errors_{year}.csv", index=False)
        still_errors_pt.to_csv(path_still_errors / f"still_errors_{year}.csv", index=False)

    pd.DataFrame(metadata).to_csv(path_metadata / f"metadata_{year}.csv", index=False)
    pd.DataFrame(errors).to_csv(errors_dir / f"errors_{year}.csv", index=False)
      
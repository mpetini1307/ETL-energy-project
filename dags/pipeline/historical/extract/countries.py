import logging
import pandas as pd
import requests
import os

from pipeline.config import (
    DATA_DIR,
    COUNTRY_API_KEY,
    COUNTRY_URL
)

log = logging.getLogger(__name__)



def download_countries():
    path_folder = DATA_DIR / "countries"
    path_folder.mkdir(parents=True, exist_ok=True)
    path_file = path_folder / "countries.csv"
    if os.path.exists(path_file):
       log.info("Already downloaded : %s", path_file)
       return
    params = {"limit": 5, "offset": 0}
    countries = []

    while True:
        resp = requests.get(COUNTRY_URL, headers={"Authorization": COUNTRY_API_KEY},params=params)
        contenu = resp.json()["data"]

        for p in contenu["objects"]:
            countries.append({
                "code": p["codes"]["alpha_2"],
                "pays": p["names"]["common"],
                "latitude": p["coordinates"]["lat"],
                "longitude": p["coordinates"]["lng"],
            })

        if not contenu["meta"]["more"]:
            break
        params["offset"] += 5

    path_folder = DATA_DIR / "countries"
    path_folder.mkdir(parents=True, exist_ok=True)
    pd.DataFrame(countries).to_csv(path_folder / "countries.csv", index=False)
    log.info("%d pays téléchargés", len(countries))
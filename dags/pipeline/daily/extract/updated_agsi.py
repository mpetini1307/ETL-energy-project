import logging
import time
import pandas as pd
import requests
import os
from datetime import date, timedelta

from pipeline.config import (
    DATA_DIR,
    AGSI_API_KEY,
    AGSI_URL,
    AGSI_COUNTRY_URL,
    DATA_DIR_UPDATE
)

log = logging.getLogger(__name__)

def country_list():
    operators = requests.get(AGSI_COUNTRY_URL,
                       headers={"x-key": AGSI_API_KEY}).json()
    country = []
    for operator in operators:
        if operator['country'] not in country:
            country.append(operator['country'])

    return country


def download_agsi_per_country(country, day):
    metadata = []
    path_folder = DATA_DIR_UPDATE / "agsi" / f'{day}'
    path_metadata = DATA_DIR_UPDATE / "agsi" / f'{day}' / "metadata"
    if not os.path.exists(path_folder): os.makedirs(path_folder)
    if not os.path.exists(path_metadata): os.makedirs(path_metadata)
    path_file = path_folder / f"updated_agsi_{country}.csv"

    params = {"country": country, "from": day.isoformat(), "to": day.isoformat(), "size": 300}

    start = time.perf_counter()
    resp = requests.get(AGSI_URL, headers={"x-key": AGSI_API_KEY}, params=params, timeout=60)
    resp.raise_for_status()
    df_data = pd.DataFrame(resp.json()["data"])

    df_data.to_csv(path_file, index=False)
    duration = time.perf_counter() - start
    sizeMo = os.path.getsize(path_file)/(1024*1024)
    lines = df_data.shape[0]
    metadata.append({
                "status" : "ok",
                "web" : "agsi",
                "day": day.isoformat(),
                "size(Mo)": sizeMo,
                "time(s)": duration,
                "lines": lines
            })

    log.info("Storage of %s for %s is written - %d lines - %f Mo - %f(s)", country, day, lines, sizeMo, duration)
    pd.DataFrame(metadata).to_csv(path_metadata / f"metadata_updated_agsi_{country}_{day.isoformat()}.csv", index=False)


def download_agsi(day):
    countries = country_list()
    for country in countries:
        download_agsi_per_country(country, day)
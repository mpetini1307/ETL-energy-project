import logging
import time
import pandas as pd
import requests
import os 

from pipeline.config import (
    DATA_DIR,
    AGSI_API_KEY,
    AGSI_URL,
    AGSI_COUNTRY_URL
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


def download_agsi_per_country(country):
    metadata =[]
    path_folder = DATA_DIR / "agsi" 
    path_metadata = path_folder / "metadata"
    if not os.path.exists(path_folder): os.makedirs(path_folder)
    if not os.path.exists(path_metadata): os.makedirs(path_metadata)
    path_file = path_folder / f"agsi_{country}.csv"
    if path_file.exists(): 
        print("already downloaded")
        return None 
    params = {"country": f"{country}", "size": 300, "page": 0, "to":"2026-10-10"}

    start = time.perf_counter()
    gas_storage = requests.get(AGSI_URL, headers={"x-key": AGSI_API_KEY}, params=params).json()

    df_total_data = pd.DataFrame()

    for page_number in range(1,gas_storage["last_page"] + 1):
        params["page"] = page_number
        df_data_paged = pd.DataFrame(requests.get(AGSI_URL, headers={"x-key": AGSI_API_KEY}, params=params).json()["data"])

        df_total_data = pd.concat([df_total_data,df_data_paged], ignore_index=True)

    df_total_data.to_csv(path_file,index=False)
    duration = time.perf_counter() - start
    sizeMo = os.path.getsize(path_file)/(1024*1024)
    lines = df_total_data.shape[0]
    metadata.append({
                "status" : "ok",
                "web" : "agsi",
                "size(Mo)": sizeMo,
                "time(s)": duration,
                "lines": lines
            })
    
    log.info("Storage of %s is written - %d lines - %f Mo - %f(s)",country,lines,sizeMo,duration)
    pd.DataFrame(metadata).to_csv(path_metadata / f"metadata_agsi_{country}.csv", index=False)

def download_agsi():
    countries = country_list()
    for country in countries:
        download_agsi_per_country(country)

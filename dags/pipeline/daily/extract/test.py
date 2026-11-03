import json
import logging
import time
import pandas as pd
import requests
import os 
from datetime import datetime

from pipeline.config import (
    ENTSOG_DOWNLOAD_URL,
)

from pipeline.config import (
    ENTSOE_DOWNLOAD_URL,
    ENTSOE_PWD,
    ENTSOE_USER,
    ENTSOE_FOLDER_URL,
    ENTSOE_KEYCLOAK_URL,
    DATA_DIR,
)

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

LIST_URL = "https://fms.tp.entsoe.eu/listFolder"   # vérifie l'URL utilisée dans ta fonction list_files

payload = json.dumps({
    "path": "/TP_export/",
    "pageInfo": {"pageIndex": 0, "pageSize": 5000},
})

resp = requests.post(LIST_URL, headers=get_headers(), data=payload)
resp.raise_for_status()

df = pd.DataFrame(resp.json()["contentItemList"])
ligne = df[df["name"] == "ActualTotalLoad_6.1.A_r3"]
print(ligne)
print(df)
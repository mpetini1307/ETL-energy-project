import eurostat
import logging
import time
import pandas as pd
import os 

from pipeline.config import (
    DATA_DIR,
    EUROSTAT_DB_TO_DL
)

log = logging.getLogger(__name__)

def download_eurostat(database):
    metadata=[]
    writing_folder = DATA_DIR / "eurostat"

    os.makedirs(writing_folder, exist_ok=True)

    writing_file = writing_folder / f"{database}.csv" 

    start = time.perf_counter()
    df = eurostat.get_data_df(database)
    df.to_csv(writing_file,index=False)

    
    duration = time.perf_counter() - start
    size_mo = os.path.getsize(writing_file)/(1024*1024)
    lines = df.shape[0]
    metadata.append({
            "status" : "ok",
            "web" : "eurostat",
            "size(Mo)": size_mo,
            "time(s)": duration,
            "lines": lines
        })
    log.info("%s : %d lines - %.2f Mo - %f (s)",database,lines,size_mo,duration)
    path_metadata = writing_folder/ "metadata"
    if not os.path.exists(path_metadata) : os.makedirs(path_metadata)
    pd.DataFrame(metadata).to_csv(path_metadata / f"metadata_{database}.csv",index=False)

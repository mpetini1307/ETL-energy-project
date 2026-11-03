import csv
from datetime import date, datetime, timedelta
from pipeline.config import DATA_DIR

WATERMARK_FILE = DATA_DIR / "watermark.csv"

def get_watermark():
    with open(WATERMARK_FILE, newline="") as f:
        lignes = list(csv.DictReader(f))
    return date.fromisoformat(lignes[-1]["date_recuperee"])

def add_watermark():
    nouveau = not WATERMARK_FILE.exists()
    with open(WATERMARK_FILE, "a", newline="") as f:
        writer = csv.writer(f)
        if nouveau:
            writer.writerow(["run", "date_recuperee"])
        writer.writerow([
            datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            (date.today() - timedelta(days=1)).isoformat(),
        ])
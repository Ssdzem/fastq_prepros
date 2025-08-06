import sys
import os
import shutil
from glob import glob
import pandas as pd

def validate_sample(metadata_csv, project, bundle_uuid):
    df = pd.read_csv(metadata_csv)
    df.columns = df.columns.str.lower()
    if df[(df["proyect"] == project) & (df["bundle_uuid"] == bundle_uuid)].empty:
        raise ValueError(f"[!] No matching entry for project='{project}', bundle_uuid='{bundle_uuid}'.")    
    return project, bundle_uuid

def filter_and_preprocess(raw_dir, sample_id, output_r1, output_r2):
    raw_sample_dir = os.path.join(raw_dir, sample_id)
    if not os.path.exists(raw_sample_dir):
        raise FileNotFoundError(f"[!] Sample directory '{raw_sample_dir}' not found.")

    raw_fastqs = sorted(glob(os.path.join(raw_sample_dir, "*.fastq.gz")))
    r1_files = [f for f in raw_fastqs if "R1" in f]
    r2_files = [f for f in raw_fastqs if "R2" in f]

    if not r1_files or not r2_files:
        raise ValueError(f"[!] No R1 or R2 files found in '{raw_sample_dir}'.")

    os.makedirs(os.path.dirname(output_r1), exist_ok=True)
    
    with open(output_r1, "wb") as r1_out:
        for file in r1_files:
            with open(file, "rb") as f:
                shutil.copyfileobj(f, r1_out)

    with open(output_r2, "wb") as r2_out:
        for file in r2_files:
            with open(file, "rb") as f:
                shutil.copyfileobj(f, r2_out)

if __name__ == "__main__":
    raw_dir     = sys.argv[1]
    bundle_uuid = sys.argv[2]
    project     = sys.argv[3]
    metadata    = sys.argv[4]
    output_r1   = sys.argv[5]
    output_r2   = sys.argv[6]

    # Step 1: Check if sample is in the metadata
    validate_sample(metadata, project, bundle_uuid)

    # Step 2: Proceed with normal concatenation
    filter_and_preprocess(raw_dir, bundle_uuid, output_r1, output_r2)

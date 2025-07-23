import sys
import os
import shutil
from glob import glob

def filter_and_preprocess(raw_dir, sample_id, output_r1, output_r2):
    raw_sample_dir = os.path.join(raw_dir, sample_id)
    if not os.path.exists(raw_sample_dir):
        raise FileNotFoundError(f"Sample directory {raw_sample_dir} not found.")

    raw_fastqs = sorted(glob(os.path.join(raw_sample_dir, "*.fastq.gz")))
    r1_files = [f for f in raw_fastqs if "_R1_" in f]
    r2_files = [f for f in raw_fastqs if "_R2_" in f]

    if not r1_files or not r2_files:
        raise ValueError(f"No R1 or R2 files found in {raw_sample_dir}.")

    os.makedirs(os.path.dirname(output_r1), exist_ok=True)
    with open(output_r1, "wb") as r1_out:
        for file in r1_files:
            with open(file, "rb") as f:
                r1_out.write(f.read())

    with open(output_r2, "wb") as r2_out:
        for file in r2_files:
            with open(file, "rb") as f:
                r2_out.write(f.read())

if __name__ == "__main__":
    raw_dir = sys.argv[1]
    sample_id = sys.argv[2]
    output_r1 = sys.argv[3]
    output_r2 = sys.argv[4]
    filter_and_preprocess(raw_dir, sample_id, output_r1, output_r2)

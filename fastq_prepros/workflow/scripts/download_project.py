import sys
import os
import subprocess

def download_project(curl, output_dir):
    os.makedirs(output_dir, exist_ok=True)
    tar_file = os.path.join(output_dir, "fastqs.tar.gz")
    subprocess.run(f"curl -o {tar_file} {curl}", shell=True, check=True)
    subprocess.run(f"tar -xzvf {tar_file} -C {output_dir}", shell=True, check=True)
    os.remove(tar_file)

if __name__ == "__main__":
    curl = sys.argv[1]
    output_dir = sys.argv[2]
    download_project(curl, output_dir)

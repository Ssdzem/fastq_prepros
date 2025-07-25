import sys
import os
import subprocess

def download_project(curl_cmd, output_dir):
    os.makedirs(output_dir, exist_ok=True)
    # Run the full curl pipeline directly inside output_dir:
    subprocess.run(curl_cmd, shell=True, cwd=output_dir, check=True)

if __name__ == "__main__":
    curl_cmd = sys.argv[1]
    output_dir = sys.argv[2]
    download_project(curl_cmd, output_dir)

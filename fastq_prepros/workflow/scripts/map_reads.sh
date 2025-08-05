#!/usr/bin/env bash

set -euo pipefail

# Usage: map_reads.sh <FASTQ_R1> <FASTQ_R2> <GENOME_DIR> <WHITELIST> <OUTPUT_BAM> <THREADS>
if [[ $# -ne 6 ]]; then
  echo "Usage: $0 <FASTQ_R1> <FASTQ_R2> <GENOME_DIR> <WHITELIST> <OUTPUT_BAM> <THREADS>" >&2
  exit 1
fi

FASTQ_R1="$1"
FASTQ_R2="$2"
GENOME_DIR="$3"
WHITELIST="$4"
OUTPUT_BAM="$5"
THREADS="$6"

# Derive prefix for STAR outputs
OUTPUT_PREFIX="${OUTPUT_BAM%.bam}"

# Ensure output folder exists
mkdir -p "$(dirname "$OUTPUT_BAM")"

# --- Auto-detect R1 length to infer CB+UMI ---
# Grab only the first sequence line from R1 and then quit
set +o pipefail
seq=$(zcat "$FASTQ_R1" | sed -n '2{p;q;}')
set -o pipefail
TOTAL_LEN=${#seq}
echo "Detected R1 length ${TOTAL_LEN} bases" >&2

# Infer CB and UMI lengths for common 10x chemistries
if [[ "$TOTAL_LEN" -eq 28 ]]; then
  CB_LEN=16; UMI_LEN=12
elif [[ "$TOTAL_LEN" -eq 26 ]]; then
  CB_LEN=16; UMI_LEN=10
else
  echo "Warning: unexpected R1 length ${TOTAL_LEN}; defaulting CB_LEN=16, UMI_LEN=$((TOTAL_LEN-16))" >&2
  CB_LEN=16; UMI_LEN=$((TOTAL_LEN-16))
fi

echo "Using CB_LEN=${CB_LEN}, UMI_LEN=${UMI_LEN}" >&2

echo "Running STAR mapping..." >&2
echo "[$(date)] map_reads.sh starting" >&2
echo "STAR -> $(command -v STAR)" >&2
STAR --version >&2
echo "Running STAR mapping…" >&2

# ---- STAR Solo mapping ----
STAR --runThreadN "$THREADS" \
     --readFilesIn "$FASTQ_R2" "$FASTQ_R1" \
     --readFilesCommand zcat \
     --genomeDir "$GENOME_DIR" \
     --outSAMtype BAM SortedByCoordinate \
     --outFileNamePrefix "$OUTPUT_PREFIX" \
     --soloType CB_UMI_Simple \
     --soloCBwhitelist "$WHITELIST" \
     --soloCBstart 1 --soloCBlen "$CB_LEN" \
     --soloUMIstart $((CB_LEN+1)) --soloUMIlen "$UMI_LEN" \
     --soloBarcodeReadLength "$TOTAL_LEN"

# Move the BAM into place
mv "${OUTPUT_PREFIX}Aligned.sortedByCoord.out.bam" "$OUTPUT_BAM"

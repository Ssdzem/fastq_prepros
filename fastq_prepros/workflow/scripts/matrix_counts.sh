#!/usr/bin/env bash
set -euo pipefail

FASTQ_R1=$1            # always R1
FASTQ_R2=$2            # always R2
GENOME_DIR=$3
CB_WHITELIST=$4
OUTPUT_PREFIX=$5       # e.g. output/counts/.../{sample}_
OUTPUT_MATRIX=$6       # e.g. output/counts/.../{sample}_matrix.txt
THREADS=$7

# 1) Auto-detect R1 length
set +o pipefail
seq=$(zcat "$FASTQ_R1" | sed -n '2{p;q;}')
set -o pipefail
TOTAL_LEN=${#seq}

# 2) Infer CB/UMI lengths
if   [[ "$TOTAL_LEN" -eq 28 ]]; then CB_LEN=16; UMI_LEN=12
elif [[ "$TOTAL_LEN" -eq 26 ]]; then CB_LEN=16; UMI_LEN=10
else CB_LEN=16; UMI_LEN=$((TOTAL_LEN-16)); fi

echo "Detected R1=${TOTAL_LEN}, CB=${CB_LEN}, UMI=${UMI_LEN}" >&2

# 3) Ensure output dir
mkdir -p "$(dirname "$OUTPUT_MATRIX")"

# 4) Run STARsolo—R1 then R2, guaranteed
STAR --runThreadN "$THREADS" \
     --genomeDir "$GENOME_DIR" \
     --readFilesIn "$FASTQ_R2" "$FASTQ_R1halo4yhaloreach" \
     --readFilesCommand zcat \
     --soloType CB_UMI_Simple \
     --soloCBwhitelist "$CB_WHITELIST" \
     --soloFeatures Gene \
     --soloUMIlen "$UMI_LEN" \
     --soloCBlen "$CB_LEN" \
     --soloBarcodeReadLength "$TOTAL_LEN" \
     --soloUMIfiltering MultiGeneUMI \
     --outFileNamePrefix "${OUTPUT_PREFIX}"

# 5) Find and move the matrix file
SOLO_DIR="${OUTPUT_PREFIX}Solo.out"
if [[ -f "${SOLO_DIR}/Gene/matrix.txt" ]]; then
  mv "${SOLO_DIR}/Gene/matrix.txt" "$OUTPUT_MATRIX"
elif [[ -f "${SOLO_DIR}/Gene/raw/matrix.mtx" ]]; then
  mv "${SOLO_DIR}/Gene/raw/matrix.mtx" "$OUTPUT_MATRIX"
else
  echo "Error: could not find STAR Solo matrix under ${SOLO_DIR}/Gene" >&2
  exit 1
fi

#!/bin/bash

# Arguments
INPUT_BAM=$1
GENOME_DIR=$2
OUTPUT_MATRIX=$3

# Extract output prefix (remove _matrix.txt extension)
OUTPUT_PREFIX=${OUTPUT_MATRIX%_matrix.txt}

# STAR count matrix generation
STAR --runThreadN 8 \
--readFilesIn "$INPUT_BAM" \
--genomeDir "$GENOME_DIR" \
--soloType CB_UMI_Simple \
--soloCBwhitelist "$GENOME_DIR/whitelist.txt" \
--soloFeatures Gene \
--soloUMIlen 12 \
--soloCBlen 16 \
--soloBarcodeReadLength 28 \
--outFileNamePrefix "$OUTPUT_PREFIX" \
--soloUMIfiltering MultiGeneUMI

#!/bin/bash

# Arguments
FASTQ_R1=$1
FASTQ_R2=$2
GENOME_DIR=$3
OUTPUT_BAM=$4
THREADS=$5

# Extract output prefix (remove .bam extension)
OUTPUT_PREFIX=${OUTPUT_BAM%.bam}

# STAR mapping
STAR --runThreadN "$THREADS" \
--readFilesIn "$FASTQ_R1" "$FASTQ_R2" \
--genomeDir "$GENOME_DIR" \
--outSAMtype BAM SortedByCoordinate \
--outFileNamePrefix "$OUTPUT_PREFIX" \
--soloType CB_UMI_Simple \
--soloCBwhitelist "$GENOME_DIR/whitelist.txt"

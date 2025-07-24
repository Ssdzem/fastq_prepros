#!/bin/bash
FASTQ_R1=$1
FASTQ_R2=$2
GENOME_DIR=$3
WHITELIST=$4
OUTPUT_BAM=$5
THREADS=$6

OUTPUT_PREFIX=${OUTPUT_BAM%.bam}

mkdir -p "$(dirname "$OUTPUT_BAM")"

STAR --runThreadN "$THREADS" \
     --readFilesIn "$FASTQ_R1" "$FASTQ_R2" \
     --readFilesCommand zcat \
     --genomeDir "$GENOME_DIR" \
     --outSAMtype BAM SortedByCoordinate \
     --outFileNamePrefix "$OUTPUT_PREFIX" \
     --soloType CB_UMI_Simple \
     --soloCBwhitelist "$WHITELIST"

mv "${OUTPUT_PREFIX}Aligned.sortedByCoord.out.bam" "$OUTPUT_BAM"

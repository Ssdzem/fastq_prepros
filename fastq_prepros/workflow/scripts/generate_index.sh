#!/bin/bash

# Arguments
GENOME_FASTA=$1
GTF_FILE=$2
WHITELIST=$3
OUTPUT_DIR=$4

# STAR index generation
STAR --runThreadN 20 \
--runMode genomeGenerate \
--genomeDir "$OUTPUT_DIR" \
--genomeFastaFiles "$GENOME_FASTA" \
--sjdbGTFfile "$GTF_FILE" \
--genomeSAindexNbases 12

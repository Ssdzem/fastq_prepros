# workflow/scripts/matrix_counts.sh
#!/bin/bash

# Arguments
INPUT_BAM=$1          # e.g. output/bam/<project>/<sample>.bam
GENOME_DIR=$2         # e.g. input/index/ch38ref
OUTPUT_MATRIX=$3      # e.g. output/counts/<project>/<sample>_matrix.txt
THREADS=$4            # de config["star_threads"]

# Calcula el prefijo (quita _matrix.txt)
OUTPUT_PREFIX=${OUTPUT_MATRIX%_matrix.txt}

# Asegura que exista la carpeta de salida
mkdir -p "$(dirname "$OUTPUT_MATRIX")"

# Genera la matriz de conteo con STAR Solo
STAR --runThreadN "$THREADS" \
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

# (Opcional) Mueve el archivo resultante al nombre esperado
# STAR Solo deja la matriz en ${OUTPUT_PREFIX}Solo.out/Gene/…
# Ajusta según tu versión de STAR:
mv "${OUTPUT_PREFIX}Solo.out/Gene/matrix.txt" "$OUTPUT_MATRIX"

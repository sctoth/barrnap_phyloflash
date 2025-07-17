#!/bin/bash
# ------------------------------------ #
#$ -S /bin/bash
#$ -q sThC.q
#$ -cwd
#$ -j y
#$ -N merge_files
#$ -o logs/merge_files.log
#$ -m bea
#$ -M sctoth@ncsu.edu
# ------------------------------------ #
set -eu
MAIN_DIR="/scratch/public/genomics/toths/biocode_fish_genome_skimming"
SAMPLE_LIST="${MAIN_DIR}/sample_list_bacteria_all.txt"
RRNA_GENE="16S"
# ------------------------------------ #
MASTER_OUT="${MAIN_DIR}/biocode_fish_barrnap/biocode_fish_barrnap_${RRNA_GENE}/${RRNA_GENE}_blast_taxonomy_all_with_megahit_metadata_filtered.csv"

if [ ! -s "$SAMPLE_LIST" ]; then
    echo "Sample list is empty or missing!" >&2
    exit 1
fi

# Add header (from first sample)
FIRST_SAMPLE=$(head -n 1 "$SAMPLE_LIST")
HEADER_FILE="${MAIN_DIR}/biocode_fish_barrnap/biocode_fish_barrnap_${RRNA_GENE}/${FIRST_SAMPLE}_metadata/${FIRST_SAMPLE}_${RRNA_GENE}_blast_taxonomy_all_with_megahit_metadata_filtered.csv"
head -n 1 "$HEADER_FILE" > "$MASTER_OUT"

# Concatenate all files (skip header for each)
while read -r SAMPLE; do
    FILE="${MAIN_DIR}/biocode_fish_barrnap/biocode_fish_barrnap_${RRNA_GENE}/${SAMPLE}_metadata/${SAMPLE}_${RRNA_GENE}_blast_taxonomy_all_with_megahit_metadata_filtered.csv"
    if [ -f "$FILE" ]; then
        echo "Merging $FILE"
        tail -n +2 "$FILE" >> "$MASTER_OUT"
    else
        echo "Warning: $FILE does not exist" >&2
    fi
done < "$SAMPLE_LIST"

echo "Merge completed at $(date)"

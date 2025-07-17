#!/bin/bash

# Define paths
BASE_DIR="/scratch/public/genomics/toths/biocode_fish_genome_skimming/biocode_fish_barrnap/biocode_fish_barrnap_16S"
SAMPLE_LIST="/scratch/public/genomics/toths/biocode_fish_genome_skimming/sample_list_bacteria_all.txt"
OUTPUT="16S_blast_eukaryota_only_ids.txt"


# Clear output file if exists
> "$OUTPUT"

cd "$BASE_DIR"
# Loop over each sample
while read sample; do
    CSV="$BASE_DIR/${sample}_metadata/${sample}_16S_blast_eukaryota_only.csv"
    if [[ -f "$CSV" ]]; then
        # Extract query_id column (assumes it is the first column, if not adjust accordingly)
        awk -F, 'NR>1 {print $1}' "$CSV" >> "$OUTPUT"
    else
        echo "Warning: $CSV not found" >&2
    fi
done < "$SAMPLE_LIST"


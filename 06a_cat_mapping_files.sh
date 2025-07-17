#!/bin/bash

# Directory containing mapping results
MAIN_DIR="/scratch/public/genomics/toths/biocode_fish_genome_skimming"
BASE_DIR="${MAIN_DIR}/biocode_fish_barrnap_phylofish_mapping"

# List of samples (one per line)
SAMPLE_LIST="${MAIN_DIR}/sample_list_bacteria_all.txt"

cd "$BASE_DIR"

# Output file
OUTPUT="all_samples_combined_mapping_results.tsv"

# Remove output file if it already exists
rm -f "$OUTPUT"

# Write header only once, from the first file that exists
HEADER_WRITTEN=false

while read -r SAMPLE; do
    FILE="$BASE_DIR/$SAMPLE/${SAMPLE}_mapping_results_with_headers.tsv"
    if [[ -f "$FILE" ]]; then
        if [ "$HEADER_WRITTEN" = false ]; then
            # Write header from first file
            head -n 1 "$FILE" > "$OUTPUT"
            HEADER_WRITTEN=true
        fi
        # Skip header, append data
        tail -n +2 "$FILE" >> "$OUTPUT"
    else
        echo "Warning: File not found for sample $SAMPLE: $FILE"
    fi
done < "$SAMPLE_LIST"


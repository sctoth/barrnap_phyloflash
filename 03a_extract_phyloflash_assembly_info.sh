#!/bin/bash

PARENT_DIR=$(pwd)

MISSING_BOTH_FILE="$PARENT_DIR/phyloflash_error.txt"
ONLY_PHYLOFLASH_FILE="$PARENT_DIR/only_NTUs.txt"
HAS_CSV_FILE="$PARENT_DIR/RRNA_SSUs_assemblies.txt"

# Clear/create output files
: > "$MISSING_BOTH_FILE"
: > "$ONLY_PHYLOFLASH_FILE"
: > "$HAS_CSV_FILE"

# Loop through all immediate subdirectories inside PARENT_DIR
shopt -s nullglob

for subdir in "$PARENT_DIR"/*/ ; do
    base=$(basename "$subdir")

    csv_file="${subdir}${base}.phyloFlash.extractedSSUclassifications.csv"
    phylo_file="${subdir}${base}.phyloFlash"   # Adjust extension if needed

    csv_exists=false
    phylo_exists=false

    [[ -f "$csv_file" ]] && csv_exists=true
    [[ -f "$phylo_file" ]] && phylo_exists=true

    if $csv_exists; then
        # Has CSV file (regardless of phyloflash)
        echo "$base" >> "$HAS_CSV_FILE"
    else
        if $phylo_exists; then
            # Has phyloflash only (no csv)
            echo "$base" >> "$ONLY_PHYLOFLASH_FILE"
        else
            # Missing both files
            echo "$base" >> "$MISSING_BOTH_FILE"
        fi
    fi
done

echo "Done."
echo "Sample missing both files: $MISSING_BOTH_FILE"
echo "Sample with only .phyloflash file: $ONLY_PHYLOFLASH_FILE"
echo "Sample with .phyloFlash.extractedSSUclassifications.csv file: $HAS_CSV_FILE"

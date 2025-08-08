#!/bin/bash
set -euo pipefail

MAIN_DIR="/scratch/public/genomics/toths/biocode_fish_genome_skimming"
BASE_DIR="${MAIN_DIR}/biocode_fish_barrnap_phylofish_mapping"
SAMPLE_LIST="${MAIN_DIR}/sample_list_bacteria_all.txt"
COMBINED="${BASE_DIR}/all_unmapped_samples_combined.tsv"
METADATA_CSV="${MAIN_DIR}/biocode_fish_barrnap/biocode_fish_barrnap_16S/all_samples_16S_blast_taxonomy_with_megahit_metadata.counted.csv"
FINAL_OUTPUT="${BASE_DIR}/all_unmapped_samples_combined_metadata.tsv"

# Combine all qseqids
echo -e "qseqid" > "$COMBINED"
while read SAMPLE; do
    FILE="${BASE_DIR}/${SAMPLE}/${SAMPLE}_unmapped_query_ids.txt"
    if [ -f "$FILE" ]; then
        cat "$FILE" >> "$COMBINED"
    else
        echo "Warning: $FILE not found, skipping."
    fi
done < "$SAMPLE_LIST"

# AWK-based join: qseqid (from COMBINED) with query_id (from METADATA)
#   Assume qseqid in $1 of COMBINED, and query_id in $1 of METADATA_CSV.
awk -F',' '
NR==FNR {
    if (FNR==1) { 
        # Save header
        for (i=1; i<=NF; i++) colname[i]=$i
        hdr=""
        for (i=1; i<=NF; i++) hdr=hdr","$i
        next
    }
    k=$1
    # Save entire line minus first column (k)
    meta[k]=$0
    next
}
FNR==1 { 
    # Print joined header: qseqid and all metadata headers (skip redundant query_id)
    printf "%s", $1
    getline < "'"$METADATA_CSV"'"
    split($0, meta_hdr, ",")
    for (j=2; j<=length(meta_hdr); j++) printf ",%s", meta_hdr[j]
    print ""
    next
}
{
    k=$1
    if (k in meta) {
        split(meta[k], arr, ",")
        # Print qseqid, then all metadata except the redundant query_id
        printf "%s", k
        for (j=2; j<=length(arr); j++) printf ",%s", arr[j]
        print ""
    }
}
' "$METADATA_CSV" "$COMBINED" > "$FINAL_OUTPUT"

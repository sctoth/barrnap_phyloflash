#!/bin/bash

# File paths
MAPPING_TSV="/scratch/public/genomics/toths/biocode_fish_genome_skimming/biocode_fish_barrnap_phylofish_mapping/all_samples_combined_mapping_results.tsv"
METADATA_CSV="/scratch/public/genomics/toths/biocode_fish_genome_skimming/biocode_fish_barrnap/biocode_fish_barrnap_16S/all_samples_16S_blast_taxonomy_with_megahit_metadata.counted.csv"
OUTPUT="merged_results.tsv"

MAIN_DIR="/scratch/public/genomics/toths/biocode_fish_genome_skimming/biocode_fish_barrnap_phylofish_mapping"

cd "$MAIN_DIR"

# Convert CSV metadata to tab-delimited (awk works easier)
TMP_META="/tmp/tmp_metadata.tsv"
tr ',' '\t' < "$METADATA_CSV" > "$TMP_META"

awk -v mapping="$MAPPING_TSV" -v meta="$TMP_META" '
    BEGIN {
        FS = "\t";
        # Read metadata headers and store field positions
        getline meta_header < meta;
        split(meta_header, mhdr, "\t");
        for(i=1;i<=length(mhdr);i++) meta_hdr[i]=mhdr[i];
        # Store metadata lines by query_id
        while((getline l < meta) > 0) {
            split(l, a, "\t");
            key=a[1]; # assuming query_id is the first col
            meta_data[key]=l;
        }
        close(meta);
        # Prepare to write output header after reading mapping header
    }
    FNR == 1 {
        split($0, thdr, "\t");
        # Prepare header for output: mapping headers + metadata (except duplicate key)
        output_header = $0;
        for(i=2;i<=length(mhdr);i++) output_header = output_header "\t" mhdr[i];
        print output_header;
        next;
    }
    FNR > 1 {
        key = $1; # assumes qseqid is 1st column
        # Output mapping columns
        printf "%s", $0;
        if (meta_data[key] != "") {
            split(meta_data[key], mval, "\t");
            for(j=2; j<=length(mval); j++) printf "\t%s", mval[j];
        } else {
            # No metadata found; print empty fields to match number of metadata columns - 1
            for(j=2; j<=length(mhdr); j++) printf "\t";
        }
        printf "\n";
    }
' "$MAPPING_TSV" > "$OUTPUT"

echo "Done. Output written to $OUTPUT"



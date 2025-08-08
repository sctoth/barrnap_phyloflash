#!/bin/bash
#$ -S /bin/sh
#$ -q sThC.q
#$ -cwd
#$ -j y
#$ -N extract_fasta_sequences
#$ -o extract_fasta_sequences.log
#$ -m bea
#$ -M sctoth@ncsu.edu

# Input fasta file
fasta="/scratch/public/genomics/toths/biocode_fish_phyloflash/fish_moorea_bacteria_phyloflash_SSUs_renamed/fish_moorea_bacteria_phyloflash_SSUs_renamed.fasta"

# Base directory for output (same as fasta directory)
base_dir=$(dirname "$fasta")

# Temporary variables
current_header=""
current_seq=""
current_group=""
outfile=""

mkdir -p "$base_dir"  # Ensure base directory exists

flush_sequence() {
    # Write the current sequence to the appropriate file if not empty
    if [[ -n "$current_header" && -n "$current_seq" ]]; then
        # Create output directory if it doesn't exist
        mkdir -p "$base_dir/$current_group"
        # Append sequence to file named after group
        echo -e "$current_header\n$current_seq" >> "$base_dir/$current_group/${current_group}.fasta"
    fi
}

while IFS= read -r line; do
    if [[ "$line" == ">"* ]]; then
        # If we already have a sequence, flush it before processing new header
        flush_sequence

        current_header="$line"
        current_seq=""
        
        # Extract the basename before the last underscore from the header
        # Remove leading '>'
        header_name="${line#>}"

        # Extract the group name by removing the last underscore and suffix
        # For example: MBIO999.PFspades_3 -> MBIO999.PFspades
        current_group="${header_name%_*}"

    else
        # Accumulate sequence lines (handles multi-line sequences)
        current_seq+="$line"$'\n'
    fi
done < "$fasta"

# Flush the last sequence after the loop ends
flush_sequence

echo "Extraction complete. Subdirectories created in $base_dir"


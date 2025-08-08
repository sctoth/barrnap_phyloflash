#!/bin/bash
# ------------------------------------ #
#$ -S /bin/sh
#$ -q sThC.q
#$ -cwd
#$ -j y
#$ -N 03_extract_fasta_seqs
#$ -o logs/03_extract_fasta_seqs.log
#$ -m bea
#$ -M sctoth@ncsu.edu
# ----------------INPUT------------------------- #
# Path to main directory, sample list and SSU rRNA of interest
MAIN_DIR="/scratch/public/genomics/toths/biocode_fish_genome_skimming"
SSU_RRNA="16S"

# Define output directory from 02_assemble_barrnap
indir="${MAIN_DIR}/biocode_fish_barrnap"
outdir="$indir/biocode_fish_barrnap_${SSU_RRNA}"

mkdir -p "$outdir"
# ----------------COMMANDS------------------------- #

# Loop through all fasta files in the input directory
for fasta in "$indir"/*.fasta; do
    # Get the base filename without path and extension
    base=$(basename "$fasta" .fasta)
    # Create output subdirectory
    subdir="$outdir/$base"
    mkdir -p "$subdir"
    # Set output file path
    outfile="$subdir/${base}_16S.fasta"
    # Extract 16S sequences
    awk '/^>16S_/{f=1} /^>/&&!/^>16S_/{f=0} f' "$fasta" > "$outfile"
done



#!/bin/bash
#$ -S /bin/sh
#$ -q sThC.q
#$ -cwd
#$ -j y
#$ -N extract_fasta_sequences
#$ -o extract_fasta_sequences.log
#$ -m bea
#$ -M sctoth@ncsu.edu

############
# Set input and output directories
indir="/scratch/public/genomics/toths/biocode_fish_genome_skimming/megahit_barrnap_output"
outdir="$indir/biocode_fish_barrnap_16S"

mkdir -p "$outdir"

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



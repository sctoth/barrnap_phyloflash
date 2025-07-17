#!/bin/bash
#$ -S /bin/sh
#$ -pe mthread 16
#$ -q sThM.q
#$ -l mres=256G,h_data=16G,h_vmem=16G,himem
#$ -cwd
#$ -j y
#$ -N blast_seqs
#$ -o blast_seqs.log
#$ -m bea
#$ -M sctoth@ncsu.edu

# Directory containing query FASTA files
module load bio/blast
indir="/scratch/public/genomics/toths/biocode_fish_genome_skimming/megahit_barrnap_output/biocode_fish_barrnap_16S"
# BLAST database
blastdb="/scratch/dbs/blast/v5/nt"

# Loop over all .fasta files in the input directory
for fasta in "$indir"/*.fasta; do
    # Get the base filename without path and extension
    base=$(basename "$fasta" .fasta)
    # Create a subdirectory for this fasta file
    outdir="$indir/${base}_blast_results"
    mkdir -p "$outdir"
    echo $fasta
    # Set output file path
    blastout="$outdir/${base}_blast.txt"
    # Run BLAST (blastn for nucleotide; use blastp for protein)
    echo -e "query_id\tsubject_id\t%identity\talignment_length\tmismatches\tgap_opens\tq_start\tq_end\ts_start\ts_end\tevalue\tbit_score\ttaxid\tscientific_name\tsuperkingdom" > "$blastout"
    blastn -query "$fasta" -db "$blastdb" \
        -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids sscinames sskingdoms" \
        -max_target_seqs 15 >> "$blastout"
    echo "BLAST complete for $fasta"
done
# ----------------Your Commands------------------- #
#
echo + `date` job $JOB_NAME started in $QUEUE with jobID=$JOB_ID on $HOSTNAME
#
#
echo = `date` job $JOB_NAME done

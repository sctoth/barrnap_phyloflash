#!/bin/bash
#$ -S /bin/bash
#$ -pe mthread 16
#$ -q sThM.q
#$ -l mres=32G,h_data=2G,h_vmem=2G,himem
#$ -cwd
#$ -j y
#$ -N map_barrnap_phyloflash
#$ -o logs/map_barrnap_phyloflash_$TASK_ID.log
#$ -m bea
#$ -M sctoth@ncsu.edu
#$ -t 1-24 -tc 24  
# ------------------------------------ #
# Load required modules
module load bio/blast
MAIN_DIR="/scratch/public/genomics/toths/biocode_fish_genome_skimming"
SAMPLE_LIST="${MAIN_DIR}/sample_list_bacteria_all.txt"
RRNA_GENE="16S"
# ------------------------------------ #
# Get the sample ID for the current task from the file
SAMPLE=$(sed -n "${SGE_TASK_ID}p" $SAMPLE_LIST)

echo "Processing sample: $SAMPLE"

## INPUT FILES
BARRNAP_SEQS="${MAIN_DIR}/biocode_fish_barrnap/biocode_fish_barrnap_${RRNA_GENE}/${SAMPLE}_barrnap_${RRNA_GENE}.fasta"

# Path to phyloflash fasta file
PHYLOFLASH_SEQS="/scratch/public/genomics/toths/biocode_fish_genome_skimming/biocode_fish_phyloflash/fish_moorea_bacteria_phyloflash_SSUs_renamed/${SAMPLE}.PFspades.fasta"

## WORKING DIRECTORY
OUTDIR="${MAIN_DIR}/biocode_fish_barrnap_phylofish_mapping/${SAMPLE}"
# ------------------------------------ #
mkdir -p "$OUTDIR"
cd "$OUTDIR" || exit 1

echo "Making BLAST database from PhyloFlash FASTA..."
makeblastdb -in "$PHYLOFLASH_SEQS" -dbtype nucl -out PF_DB

echo "Running BLASTN..."
blastn \
  -query "$BARRNAP_SEQS" \
  -db PF_DB \
  -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen" \
  -out "${SAMPLE}_mapping_results.tsv"

# Add column headers
echo -e "qseqid\tsseqid\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore\tqlen\tslen" > "${SAMPLE}_mapping_results_with_headers.tsv"
cat "${SAMPLE}_mapping_results.tsv" >> "${SAMPLE}_mapping_results_with_headers.tsv"

# Find unmapped query IDs

# Extract all query IDs from the input FASTA
grep '^>' "$BARRNAP_SEQS" | sed 's/^>//' | cut -d' ' -f1 > ""$SAMPLE"_all_query_ids.txt"

# Extract mapped query IDs from BLAST result
cut -f1 ""$SAMPLE"_mapping_results.tsv" | sort | uniq > ""$SAMPLE"_mapped_qseqids.txt"

# Fallback if process substitution isn't supported:
sort ""$SAMPLE"_all_query_ids.txt" > all_sorted.txt
sort ""$SAMPLE"_mapped_qseqids.txt" > mapped_sorted.txt
comm -23 all_sorted.txt mapped_sorted.txt > ""$SAMPLE"_unmapped_query_ids.txt"
rm all_sorted.txt mapped_sorted.txt

echo "Done processing $SAMPLE"

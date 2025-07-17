#!/bin/bash
# ------------------------------------ #
#$ -S /bin/bash
#$ -pe mthread 16
#$ -q sThC.q
#$ -l mres=32G,h_data=2G,h_vmem=2G
#$ -cwd
#$ -j y
#$ -N barrnap_metadata_all
#$ -o logs/barrnap_metadata_$TASK_ID.log
#$ -m bea
#$ -M sctoth@ncsu.edu
#$ -t 1-80 -tc 40  
# ----------------Your Commands------------------- #
module load bio/seqkit/2.8.1
MAIN_DIR="/scratch/public/genomics/toths/biocode_fish_genome_skimming"
SAMPLE_LIST="${MAIN_DIR}/sample_list.txt"
RRNA_GENE="16S"
# ------------------------------------ #
# Get the sample ID for the current task from the file
SAMPLE=$(sed -n "${SGE_TASK_ID}p" $SAMPLE_LIST)

echo "Processing sample: $SAMPLE"

export SAMPLE

# Set paths
OUT_DIR="${MAIN_DIR}/biocode_fish_barrnap/biocode_fish_barrnap_${RRNA_GENE}"
BLAST_RESULTS="${OUT_DIR}/${SAMPLE}_barrnap_${RRNA_GENE}_blast_results/${SAMPLE}_barrnap_${RRNA_GENE}_blast.txt"
MEGAHIT_RESULTS="${MAIN_DIR}/biocode_fish_barrnap/${SAMPLE}_megahit/final.contigs.fa"

# Prepare working directory
mkdir -p "${OUT_DIR}/${SAMPLE}_metadata"
cd "${OUT_DIR}/${SAMPLE}_metadata" || exit 1

# Extract first hit per query_id
awk -F"\t" '
  NR==1{print "query_id,taxid,scientific_name,superkingdom"; next}
  !seen[$1]++{print $1","$13","$14","$15}
' "$BLAST_RESULTS" > "${SAMPLE}_${RRNA_GENE}_blast_unique_taxonomy.csv"

echo "Extracted first hits" 

# Non-Eukaryota only, with sequence_name
awk -F',' -v OFS=',' '
  NR==1 { print $0, "sequence_name"; next }
  $4 != "Eukaryota" {
    match($1, /::([^:]+):/, arr)
    print $0, arr[1]
  }' "${SAMPLE}_${RRNA_GENE}_blast_unique_taxonomy.csv" > "${SAMPLE}_${RRNA_GENE}_blast_unique_taxonomy_no_eukaryota_with_seqname.csv"

# Eukaryota only, with sequence_name
awk -F',' -v OFS=',' '
  NR==1 { print $0, "sequence_name"; next }
  $4 == "Eukaryota" {
    match($1, /::([^:]+):/, arr)
    print $0, arr[1]
  }' "${SAMPLE}_${RRNA_GENE}_blast_unique_taxonomy.csv" > "${SAMPLE}_${RRNA_GENE}_blast_eukaryota_only_with_seqname.csv"

# The full CSV with sequence_name appended to every row
awk -F',' -v OFS=',' '
  NR==1 { print $0, "sequence_name"; next }
  {
    match($1, /::([^:]+):/, arr)
    print $0, arr[1]
  }' "${SAMPLE}_${RRNA_GENE}_blast_unique_taxonomy.csv" > "${SAMPLE}_${RRNA_GENE}_blast_unique_taxonomy_with_seqname.csv"

FILES=(
  "${SAMPLE}_${RRNA_GENE}_blast_unique_taxonomy_no_eukaryota_with_seqname.csv"
  "${SAMPLE}_${RRNA_GENE}_blast_unique_taxonomy_with_seqname.csv"
)
OUTS=(
  "${SAMPLE}_${RRNA_GENE}_blast_taxonomy_no_eukaryota_with_megahit_metadata_filtered.csv"
  "${SAMPLE}_${RRNA_GENE}_blast_taxonomy_all_with_megahit_metadata_filtered.csv"
)

for IDX in "${!FILES[@]}"; do
    FILE="${FILES[$IDX]}"
    CSV_OUT="${OUTS[$IDX]}"

    echo "+ Processing: $FILE -> $CSV_OUT"

    # 1. Extract unique desired sequence names (assume col 5)
    cut -d, -f5 "$FILE" | tail -n +2 | awk '{gsub(/[\r[:space:]]/, "", $0); print}' | sort -u > wanted_ids.txt

    # 2. Extract matching FASTA entries efficiently
    seqkit grep -f wanted_ids.txt "$MEGAHIT_RESULTS" -o extracted_sequences.fa

    # 3. Extract MEGAHIT metadata (header parsing via awk)
    awk '
    BEGIN {print "seqname\tflag\tmulti\tlen"}
    /^>/ {
        name = substr($1,2)
        flag = multi = len = ""
        for (i=2; i<=NF; i++) {
            if ($i ~ /^flag=/)   flag = substr($i, 6)
            if ($i ~ /^multi=/)  multi = substr($i, 7)
            if ($i ~ /^len=/)    len = substr($i, 5)
        }
        print name "\t" flag "\t" multi "\t" len
    }' extracted_sequences.fa > fasta_flags.tsv

    # 4. Join metadata to CSV, add Sample_ID
    awk -F'\t' '
    NR==FNR {
        # Build lookup table from fasta_flags.tsv
        if (FNR > 1) {
            flag[$1]=$2; multi[$1]=$3; len[$1]=$4;
        }
        next
    }
    BEGIN { OFS="," }
    FNR==1 {
        print $0, "flag", "multi", "len", "Sample_ID"; next
    }
    {
        seqname = $5
        gsub(/[\r[:space:]]/, "", seqname)
        if (seqname in flag) {
            print $0, flag[seqname], multi[seqname], len[seqname], ENVIRON["SAMPLE"]
        } else {
            print "Error: sequence_name '"seqname"' not found in MEGAHIT FASTA headers!" > "/dev/stderr"
        }
    }' fasta_flags.tsv FS=',' "$FILE" > "$CSV_OUT"
done

# Reporting
echo "+ $(date) | Sample: $SAMPLE | Gene: $RRNA_GENE | Processing complete!"
echo "= Output CSVs: ${OUTS[*]}"


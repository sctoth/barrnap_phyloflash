#!/bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -pe mthread 16
#$ -q sThC.q
#$ -l mres=32G,h_data=2G,h_vmem=2G
#$ -cwd
#$ -j y
#$ -N 01_fastp
#$ -o logs/01_fastp_$TASK_ID.log
#$ -t 1-80 -tc 40 # Example: There are 80 total samples to be processed
# ------------------------------------ #
module load bio/fastp/0.23.4
# Text file with basename of the samples to be processed
SAMPLE_LIST="/scratch/public/genomics/toths/biocode_fish_genome_skimming/sample_list_all.txt"
# Directory containing fastq files 
FASTQ_DIR="/scratch/nmnh_ocean_dna/SeqRuns/genohub40000024_Biocode2_01/run1"
cd $FASTQ_DIR

# Creates trimmed_fastq directory for downstream analysis within
mkdir -p trimmed_fastq
mkdir -p log_files
OUT_DIR="$FASTQ_DIR/trimmed_fastq"
OUT_DIR_LOG="$FASTQ_DIR/log_files"

SAMPLE=$(sed -n "${SGE_TASK_ID}p" "$SAMPLE_LIST")
echo "processing sample $SAMPLE"

R1="${SAMPLE}_R1_001.fastq.gz"
R2="${SAMPLE}_R2_001.fastq.gz"
name="$SAMPLE"

fastp -i "$R1" -I "$R2" \
  -o "$OUT_DIR/${name}_run1_R1_trimmed.fastq.gz" \
  -O "$OUT_DIR/${name}_run1_R2_trimmed.fastq.gz" \
  --detect_adapter_for_pe \
  --trim_poly_g \
  --verbose \
  --thread $NSLOTS \
  -j "$OUT_DIR_LOG/${name}.json" \
  -h "$OUT_DIR_LOG/${name}.html" \
  &> "$OUT_DIR_LOG/${name}.log.txt"

echo + `date` job $JOB_NAME started in $QUEUE with jobID=$JOB_ID on $HOSTNAME
echo + NSLOTS = $NSLOTS
echo = `date` job $JOB_NAME done



#!/bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -pe mthread 16
#$ -q sThC.q
#$ -l mres=32G,h_data=2G,h_vmem=2G
#$ -cwd
#$ -j y
#$ -N fastp_script
#$ -o fastp_script_$TASK_ID.log
#$ -t 11-402 -tc 40
# ------------------------------------ #
module load bio/fastp/0.23.4
# Directory containing fastq files 
SAMPLE_LIST="/scratch/nmnh_ocean_dna/SeqRuns/genohub40000024_Biocode2_01/run1/basenames.txt"
# There are 402 samples in basenames.txt file
FASTQ_DIR="/scratch/nmnh_ocean_dna/SeqRuns/genohub40000024_Biocode2_01/run1"
cd $FASTQ_DIR

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



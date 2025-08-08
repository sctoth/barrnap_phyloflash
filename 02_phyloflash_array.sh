# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -pe mthread 16
#$ -q sThC.q
#$ -l mres=64G,h_data=4G,h_vmem=4G
#$ -cwd
#$ -j y
#$ -N phyloflash_array_biocode_run1
#$ -o /home/toths/jobs/log_files/phyloflash_array/phyloflash_array_$TASK_ID.log

# Submit array job with 402 tasks, max 40 running at once
#$ -t 11-402 -tc 40
#
# ----------------Modules------------------------- #
module load tools/conda/23.1.0
start-conda 
conda activate phyloflash_env 

#sample list must have basename of file only eg. FLMOO_1001
SAMPLE_LIST="/scratch/nmnh_ocean_dna/SeqRuns/genohub40000024_Biocode2_01/run1/basenames.txt"
FASTQ_DIR="/scratch/nmnh_ocean_dna/SeqRuns/genohub40000024_Biocode2_01/run1/trimmed_fastq"
OUT_DIR="$FASTQ_DIR/phyloflash_output_run1"

mkdir -p "$OUT_DIR"
cd "$OUT_DIR"

#sample = (task array)th line on sample list
SAMPLE=$(sed -n "${SGE_TASK_ID}p" "$SAMPLE_LIST")

echo processing sample $SAMPLE

mkdir -p "$SAMPLE"
cd "$SAMPLE"
phyloFlash.pl \
-dbhome /scratch/public/genomics/siua/databases/phyloflash_db/138.1 \
-CPUs "$NSLOTS" \
-lib "$SAMPLE" \
-read1 "${FASTQ_DIR}/${SAMPLE}_run1_R1_trimmed.fastq.gz" \
-read2 "${FASTQ_DIR}/${SAMPLE}_run1_R2_trimmed.fastq.gz"

cd ../

echo finished sample $SAMPLE as SGE_TASK_ID $SGE_TASK_ID
echo + `date` job $JOB_NAME started in $QUEUE with jobID=$JOB_ID on $HOSTNAME
echo + NSLOTS = $NSLOTS
#
#
echo `date` job $JOB_NAME and task id $SGE_TASK_ID done

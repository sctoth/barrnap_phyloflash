#!/bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -pe mthread 16
#$ -q sThM.q
#$ -l mres=256G,h_data=16G,h_vmem=16G,himem
#$ -l ssd_res=200G
#$ -v SSD_SAVE_MAX=0
#$ -cwd
#$ -j y
#$ -N megahit_onecubic
#$ -o /scratch/nmnh_ocean_dna/Biocode2/jobs/logs/megahit_one_cubic_logs/megahit_onecubic_$TASK_ID.log
#$ -t 1 
# ----------------Modules------------------------- #
module load tools/ssd
module load bio/megahit/1.2.9

# sample list must have basename of file only, e.g. FLMOO_1001
FASTQ_DIR="/scratch/nmnh_ocean_dna/Biocode2/genohub40000024/combined_runs/P1_P2_P3EX/combined_runs_02"
SAMPLE_LIST="/scratch/nmnh_ocean_dna/SeqRuns/genohub40000024_Biocode2_01/run1/trimmed_fastq/trimmed_names_with_DL540.txt"
OUT_DIR="$FASTQ_DIR/megahit_output"

# Get sample from task array
sample=$(sed -n "${SGE_TASK_ID}p" "$SAMPLE_LIST")
echo processing sample $sample

mkdir -p "$OUT_DIR"
cd "$OUT_DIR"

# Run MEGAHIT assembly
megahit \
    --num-cpu-threads "$NSLOTS" \
    --tmp-dir "$SSD_DIR" \
    -1 "${FASTQ_DIR}/${sample}_combined_R1_trimmed.fastq.gz" \
    -2 "${FASTQ_DIR}/${sample}_combined_R2_trimmed.fastq.gz" \
    -o "${sample}_megahit"

echo finished sample $sample as SGE_TASK_ID $SGE_TASK_ID
echo + `date` job $JOB_NAME started in $QUEUE with jobID=$JOB_ID on $HOSTNAME
echo + NSLOTS = $NSLOTS
echo `date` job $JOB_NAME and task id $SGE_TASK_ID done

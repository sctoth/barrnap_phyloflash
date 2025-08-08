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
#$ -N 02_barrnap_only
#$ -o logs/02_barrnap_only_$TASK_ID.log
#$ -t 1-80 -tc 40  

# ----------------Modules------------------------- #
module load tools/conda/23.1.0
start-conda
conda activate barrnap_env
module load tools/ssd

# ----------------INPUT------------------------- #
MAIN_DIR="/scratch/public/genomics/toths/biocode_fish_genome_skimming"
SAMPLE_LIST="${MAIN_DIR}/sample_list.txt"
OUT_DIR="${MAIN_DIR}/biocode_fish_barrnap"

# Ensure output directory exists!
mkdir -p "$OUT_DIR"

cd "$OUT_DIR"
sample=$(sed -n "${SGE_TASK_ID}p" "$SAMPLE_LIST")
echo "processing sample $sample"

mkdir -p "${sample}_barrnap"
cd "${sample}_barrnap"

# rRNA prediction with Barrnap
# Path assumes MEGAHIT output already exists in $OUT_DIR/${sample}_megahit/final.contigs.fa
barrnap \
    --threads "$NSLOTS" \
    -k euk \
    -o "${sample}_barrnap.fasta" ../"${sample}_megahit/final.contigs.fa"

cp *_barrnap.fasta ../ || echo "No barrnap FASTA files to copy"
cd ../
rm -r "${sample}_barrnap"

echo "finished sample $sample as SGE_TASK_ID $SGE_TASK_ID"
echo "+ $(date) job $JOB_NAME started in $QUEUE with jobID=$JOB_ID on $HOSTNAME"
echo "+ NSLOTS = $NSLOTS"
echo "$(date) job $JOB_NAME and task id $SGE_TASK_ID done"


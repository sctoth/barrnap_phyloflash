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
#$ -N 02_assemble_barrnap
#$ -o logs/02_assemble_barrnap_$TASK_ID.log
#$ -t 1-80 -tc 40  
# ----------------Modules------------------------- #
module load tools/conda/23.1.0
start-conda 
conda activate barrnap_env 

module load tools/ssd
# barrnap has been downloaded in this environment
module load bio/megahit/1.2.9 

# ----------------INPUT------------------------- #
# Path to main directory, sample list and SSU rRNA of interest
MAIN_DIR="/scratch/public/genomics/toths/biocode_fish_genome_skimming"
SAMPLE_LIST="${MAIN_DIR}/sample_list.txt"

# Trimmed fastq sequences to be assembled (output directory from 01_fastp_array.sh)
FASTQ_DIR="/scratch/public/genomics/vohsens/biocode_fish_phyloflash/trimmed_fastq"

# Create output directory
OUT_DIR="${MAIN_DIR}/biocode_fish_barrnap"
mkdir -p "$OUT_DIR"

# ----------------COMMANDS------------------------- #
#sample = (task array)th line on sample list
sample=$(sed -n "${SGE_TASK_ID}p" "$SAMPLE_LIST")
echo processing sample $sample

cd "$OUT_DIR"

# assembly with MEGAHIT
megahit \
    --num-cpu-threads "$NSLOTS" \
    --tmp-dir "$SSD_DIR" \
    -1 "${FASTQ_DIR}/${sample}_R1_trimmed.fastq.gz" \
    -2 "${FASTQ_DIR}/${sample}_R2_trimmed.fastq.gz" \
    -o "${sample}_megahit"
    #creates final.contigs.fa in output directory  

mkdir -p "${sample}_barrnap" 
cd "${sample}_barrnap"
# rRNA prediction with Barrnap
# -k flag designates which kingdoms to consider when identifying rRNAs 
# can be bac, euc, arc or mito 
barrnap \
    --threads "$NSLOTS" \
    -k euk \
    -o "${sample}_barrnap.fasta" ../"${sample}_megahit/final.contigs.fa" 

#copy relevant files one directory up
cp *_barrnap.fasta ../ || echo "No barrnap FASTA files to copy"

cd ../

#remove sample directories, relevant files stored one directory up
rm -r "${sample}_barrnap"

#
echo finished sample $sample as SGE_TASK_ID $SGE_TASK_ID
echo + `date` job $JOB_NAME started in $QUEUE with jobID=$JOB_ID on $HOSTNAME
echo + NSLOTS = $NSLOTS
#
#
echo `date` job $JOB_NAME and task id $SGE_TASK_ID done

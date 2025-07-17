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
#$ -N megahit_barrnap_script_array
#$ -o megahit_barrnap_script_array_$TASK_ID.log
#$ -t 1-143 -tc 40
# ----------------Modules------------------------- #

module load tools/conda/23.1.0
start-conda 
conda activate barrnap_env 

module load tools/ssd
# barrnap has been downloaded in this environment
module load bio/megahit/1.2.9 

FASTQ_DIR="/scratch/public/genomics/vohsens/biocode_fish_phyloflash/trimmed_fastq"
SAMPLE_LIST="/scratch/public/genomics/toths/biocode_fish_genome_skimming/sample_list_no_bacteria.txt"
OUT_DIR="/scratch/public/genomics/toths/biocode_fish_genome_skimming/megahit_barrnap_output/megahit_barrnap_other_output"

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
# ----------------Your Commands------------------- #
#
echo finished sample $sample as SGE_TASK_ID $SGE_TASK_ID
echo + `date` job $JOB_NAME started in $QUEUE with jobID=$JOB_ID on $HOSTNAME
echo + NSLOTS = $NSLOTS
#
#
echo `date` job $JOB_NAME and task id $SGE_TASK_ID done

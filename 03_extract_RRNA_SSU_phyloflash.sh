#!/bin/bash
# ----------------Parameters---------------------- #
#$ -S /bin/bash
#$ -pe mthread 16
#$ -q sThC.q
#$ -l mres=64G,h_data=4G,h_vmem=4G
#$ -cwd
#$ -j y
#$ -N extract_SSU_phyloflash_01
#$ -o /scratch/nmnh_ocean_dna/Biocode2/jobs/logs/extract_SSU_phyloflash_01_logs_$JOB_ID.log
# ----------------Modules------------------------- #

indir="/scratch/nmnh_ocean_dna/Biocode2/genohub40000024/combined_runs/M997_Coral_1286/megahit_barrnap_euk_M997_CORAL1286_output"
outdir="$indir/M997_Coral_1286_barrnap_28S"

mkdir -p "$outdir"

# Internal log file only inside output directory
logfile="$outdir/extract_28S_$(date +'%Y%m%d_%H%M%S').log"

# File to record samples missing 28S sequences
missing_28S_file="$outdir/samples_missing_28S.txt"
> "$missing_28S_file"

# Counters
total_samples=0
zero_28S=0
one_28S=0
two_or_more_28S=0

# Function to prepend timestamp to each log line
log() {
    while IFS= read -r line; do
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line"
    done
}

# Redirect stdout and stderr through the log function and tee to console and logfile
exec > >(log | tee -a "$logfile") 2>&1

echo "Starting 28S extraction script"
echo "Input directory: $indir"
echo "Output directory: $outdir"
echo "Log file: $logfile"
echo ""

# Loop through all fasta files in the input directory
for fasta in "$indir"/*.fasta; do
    ((total_samples++))
    base=$(basename "$fasta" .fasta)
    subdir="$outdir/$base"
    mkdir -p "$subdir"
    outfile="$subdir/${base}_28S.fasta"

    echo "Processing file: $fasta"
    echo "Output folder: $subdir"
    echo "Output file: $outfile"

    # Extract sequences with headers starting with >28S_
    awk '/^>28S_/{f=1} /^>/&&!/^>28S_/{f=0} f' "$fasta" > "$outfile"

    if [[ -s "$outfile" ]]; then
        # Count number of 28S sequences (count headers)
        seq_count=$(grep -c "^>28S_" "$outfile")
        echo "Extraction successful: $seq_count 28S sequences written"
        if (( seq_count == 1 )); then
            ((one_28S++))
        elif (( seq_count >= 2 )); then
            ((two_or_more_28S++))
        fi
    else
        echo "Warning: No 28S sequences found in $fasta"
        rm -f "$outfile"  # Remove empty output file
        ((zero_28S++))
        echo "$base" >> "$missing_28S_file"
    fi

    echo ""
done

echo "28S extraction script completed."
echo ""

# Summary report
summary_file="$outdir/28S_extraction_summary.txt"
{
    echo "Total samples processed: $total_samples"
    echo "Samples with no 28S sequences: $zero_28S"
    echo "Samples with exactly 1 28S sequence: $one_28S"
    echo "Samples with 2 or more 28S sequences: $two_or_more_28S"
    echo ""
    echo "Samples with no 28S sequences (listed in $missing_28S_file):"
    cat "$missing_28S_file"
} > "$summary_file"

echo "Summary written to $summary_file"

exec > >(log | tee -a "$logfile") 2>&1

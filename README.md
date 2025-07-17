# barrnap_phyloflash
This is a workflow that runs MEGAHIT, barrnap and blast and compares the results to phyloflash output

Pre-req: 
1) Run phyloflash on trimmed paired-end fastq reads, extract sequences of interest if applicable
For example, we extracted sequences that were annotated to have bacteria taxonomy. 
2) Create a sample_list.txt file of the samples you want to run through the following workflow based on phyloflash sequences you want to compare to


01_fastp.sh
    Run fastp on raw fastq.gz files from pair-end reads 

02_assemble_barrnap.sh
    Assembles the reads from fastp output using megahit and subsequently runs barrnap to identify SSU rRNAs of interest (need to specify "bac", "euk", or "mito") 

03_extract_RRNA_SSU.sh
    Extracts the sequences of interest from barrnap output based on headers 
        e.g. ">16S_" 

04_blast.sh
    BLAST resulting rRNA gene sequences to nucleotide database (v5) to validate taxonomy i.e. 16S is bacterial and not eukaryotic (from 18S SSU rRNA gene)

05_append_megahit_metadata.sh
    Uses top hit from BLAST results for each sequence and appends assembly data (coverage and length) for all sequences and for sequences that are filtered based taxonomy identification (csv metadata file on all sequences and also sequences that are not eukaryotic based on BLAST search)

06_map_barrnap_phyloflash.sh
    Creates a database using the phyloflash assembly(s) and runs blastn with barrnap assemblies as the query to output coverage and percent identity. 

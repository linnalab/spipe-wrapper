#!/bin/bash

# ================= User-Defined Arguments ==================

# Base directory containing raw data sublibrary directories
RAW_DATA_BASE="/research/groups/Linna_Lab/IPSC_seq"

# List of sublibrary directories to process (full paths)
SUBLIB_DIRS=(
    "$RAW_DATA_BASE/X208SC24072023-Z02-F001/01.RawData/Sub1"
    "$RAW_DATA_BASE/X208SC24072023-Z02-F001/01.RawData/Sub2"
    "$RAW_DATA_BASE/X208SC24072023-Z02-F001/01.RawData/Sub3"
    "$RAW_DATA_BASE/X208SC24072023-Z01-F001/01.RawData/Sub4"
    "$RAW_DATA_BASE/X208SC24072023-Z01-F001/01.RawData/Sub5"
    "$RAW_DATA_BASE/X208SC24072023-Z01-F001/01.RawData/Sub6"
    "$RAW_DATA_BASE/X208SC24072023-Z01-F001/01.RawData/Sub7"
    "$RAW_DATA_BASE/X208SC24072023-Z01-F001/01.RawData/Sub8"
    "$RAW_DATA_BASE/X208SC24072023-Z01-F001/01.RawData/Undetermined"
    # Add or remove sublibraries as needed
)

# Path to the sample list file (single file for all sublibraries)
SAMPLE_LIST="/research/groups/Linna_Lab/IPSC_seq/sample-list.txt"

# Genome directory for split-pipe
GENOME_DIR="/research/groups/Linna_Lab/IPSC_seq/processed/genomes/hg38"

# Output base directory for split-pipe outputs
OUTPUT_BASE_DIR="/research/groups/Linna_Lab/IPSC_seq/processed/analysis"

# Chemistry version
CHEMISTRY="v3"

# Dry run option ("yes" for dry run, "no" for actual run)
DRY_RUN="no"

# Job configuration
TIME="1-00:00:00"
MEMORY="32G"
CPUS="8"

# ===========================================================

source ~/miniconda3/etc/profile.d/conda.sh
conda activate spipe

# Loop over each sublibrary directory
for SUBLIB_DIR in "${SUBLIB_DIRS[@]}"
do
    SUBLIB_NAME=$(basename "$SUBLIB_DIR")
    echo "Processing $SUBLIB_NAME"

    # Define paths for concatenated files within sublib_dir
    R1_CONCAT="$SUBLIB_DIR/${SUBLIB_NAME}_R1_cat.fastq.gz"
    R2_CONCAT="$SUBLIB_DIR/${SUBLIB_NAME}_R2_cat.fastq.gz"

    # Check if concatenation is necessary
    R1_FILES=("$SUBLIB_DIR"/*_1.fq.gz)
    R2_FILES=("$SUBLIB_DIR"/*_2.fq.gz)

    NUM_R1_FILES=${#R1_FILES[@]}
    NUM_R2_FILES=${#R2_FILES[@]}

    # Initialize FQ1 and FQ2
    FQ1=""
    FQ2=""

    # Check if concatenated files already exist
    CONCATENATED_R1_EXISTS=false
    CONCATENATED_R2_EXISTS=false

    if [ -f "$R1_CONCAT" ]; then
        CONCATENATED_R1_EXISTS=true
    fi
    if [ -f "$R2_CONCAT" ]; then
        CONCATENATED_R2_EXISTS=true
    fi

    # Determine FQ1 (R1) path
    if [ $NUM_R1_FILES -gt 1 ]; then
        # Multiple R1 files, concatenation needed
        if [ "$CONCATENATED_R1_EXISTS" = false ]; then
            echo "Concatenating R1 files for $SUBLIB_NAME"
            cat "${R1_FILES[@]}" > "$R1_CONCAT"
        else
            echo "Concatenated R1 file already exists for $SUBLIB_NAME"
        fi
        FQ1="$R1_CONCAT"
    elif [ $NUM_R1_FILES -eq 1 ]; then
        # Single R1 file, use it directly
        FQ1="${R1_FILES[0]}"
    else
        echo "No R1 files found for $SUBLIB_NAME"
        continue
    fi

    # Determine FQ2 (R2) path
    if [ $NUM_R2_FILES -gt 1 ]; then
        # Multiple R2 files, concatenation needed
        if [ "$CONCATENATED_R2_EXISTS" = false ]; then
            echo "Concatenating R2 files for $SUBLIB_NAME"
            cat "${R2_FILES[@]}" > "$R2_CONCAT"
        else
            echo "Concatenated R2 file already exists for $SUBLIB_NAME"
        fi
        FQ2="$R2_CONCAT"
    elif [ $NUM_R2_FILES -eq 1 ]; then
        # Single R2 file, use it directly
        FQ2="${R2_FILES[0]}"
    else
        echo "No R2 files found for $SUBLIB_NAME"
        continue
    fi

    # Prepare variables for split-pipe
    JOB_NAME="split_pipe_${SUBLIB_NAME}"
    OUTPUT_DIR="$OUTPUT_BASE_DIR/$SUBLIB_NAME"

    # Ensure the output directory exists
    mkdir -p "$OUTPUT_DIR"

    # Determine if dry run is requested
    if [ "$DRY_RUN" = "yes" ]; then
        DRY_RUN_OPTION="--dryrun"
    else
        DRY_RUN_OPTION=""
    fi

    # Submit the job with output and error paths specified
    sbatch \
      --job-name="$JOB_NAME" \
      --output="$OUTPUT_DIR/${JOB_NAME}.%j.out" \
      --error="$OUTPUT_DIR/${JOB_NAME}.%j.err" \
      --time="$TIME" \
      --mem="$MEMORY" \
      --cpus-per-task="$CPUS" \
      --export=chemistry="$CHEMISTRY",genome_dir="$GENOME_DIR",fq1="$FQ1",fq2="$FQ2",output_dir="$OUTPUT_DIR",sample_list_file="$SAMPLE_LIST",dry_run_option="$DRY_RUN_OPTION" \
      single_sublib.sbatch

done
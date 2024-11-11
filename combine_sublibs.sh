#!/bin/bash

# ================= User-Defined Arguments ==================

# Path to the manually created sublibraries list file
SUBLIB_LIST_FILE="/research/groups/Linna_Lab/IPSC_seq/sublibs.lis"

# Output directory for combined results
COMBINED_OUTPUT_DIR="/research/groups/Linna_Lab/IPSC_seq/processed/analysis/Combined"

# Job configuration
JOB_NAME="split_pipe_combine"
TIME="48:00:00"
MEMORY="120G"
CPUS="16"

# Dry run option ("yes" for dry run, "no" for actual run)
DRY_RUN="no"

# ===========================================================

# Determine if dry run is requested
if [ "$DRY_RUN" = "yes" ]; then
    DRY_RUN_OPTION="--dryrun"
else
    DRY_RUN_OPTION=""
fi

# Submit the job with SBATCH options specified directly
sbatch \
  --job-name="$JOB_NAME" \
  --output="${COMBINED_OUTPUT_DIR}/%x.%j.out" \
  --error="${COMBINED_OUTPUT_DIR}/%x.%j.err" \
  --time="$TIME" \
  --mem="$MEMORY" \
  --cpus-per-task="$CPUS" \
  --export=ALL,job_name="$JOB_NAME",time="$TIME",memory="$MEMORY",cpus="$CPUS",sublib_list_file="$SUBLIB_LIST_FILE",combined_output_dir="$COMBINED_OUTPUT_DIR",dry_run_option="$DRY_RUN_OPTION" \
  combine_sublibs.sbatch

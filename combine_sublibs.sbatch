#!/bin/bash

# Activate the conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate spipe

# Combine results
split-pipe \
   --mode comb \
   --sublib_list "${sublib_list_file}" \
   --output_dir "${combined_output_dir}" \
   ${dry_run_option}
#!/bin/bash

# Activate the conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate spipe

# Single sample run
split-pipe \
   --mode all \
   --chemistry ${chemistry} \
   --genome_dir ${genome_dir} \
   --fq1 ${fq1} \
   --fq2 ${fq2} \
   --output_dir ${output_dir} \
   --samp_list ${sample_list_file} \
   ${dry_run_option}
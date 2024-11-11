# Parse Biosciences sc/snRNA-seq Processing Pipeline Wrapper

## Introduction

This repository contains a lightweight wrapper pipeline to process Parse Biosciences sc/snRNA-seq FASTQ files using the split-pipe processing software. The scripts are designed to simplify the handling of multiple sublibrary directories, automate the concatenation of FASTQ files, and streamline the submission of processing jobs to a compute cluster.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Scripts Included](#scripts-included)
- [Usage](#usage)
  - [Step 1: Verify FASTQ Files](#step-1-verify-fastq-files)
  - [Step 2: Configure and Run `process_sublibs.sh`](#step-2-configure-and-run-process_sublibssh)
  - [Step 3: Monitor Job Progress](#step-3-monitor-job-progress)
  - [Step 4: Combine Sublibraries](#step-4-combine-sublibraries)
  - [Step 5: Verify Combined Results](#step-5-verify-combined-results)
- [Additional Notes](#additional-notes)
- [License](#license)

## Prerequisites

- **Parse Biosciences Split-pipe software**: Ensure you have installed the Split-pipe software. Installation instructions are available on the Parse Biosciences website.
- **Conda environment**: The scripts assume you have a conda environment named `spipe` with the necessary dependencies installed. The split-pipe software comes with a script that installs necessary dependencies. To run this, follow the instructions on the Parse Biosciences website.
- **Compute cluster with SLURM**: The scripts use `sbatch` to submit jobs, so you need access to a compute cluster that uses SLURM for job scheduling.
- **FASTQ files and MD5 checksums**: Your sc/snRNA-seq data in FASTQ format, along with MD5 checksum files for verification.

## Scripts Included

- `md5_checks.sh`: Verifies the integrity of your FASTQ files using MD5 checksums.
- `process_sublibs.sh`: Processes individual sublibrary directories by concatenating FASTQ files if necessary and submitting jobs to process them using Split-pipe.
- `single_sublib.sbatch`: SLURM batch script called by `process_sublibs.sh` to process a single sublibrary.
- `combine_sublibs.sh`: Submits a job to combine the results from multiple sublibraries.
- `combine_sublibs.sbatch`: SLURM batch script called by `combine_sublibs.sh` to perform the combination step.

In the future this will be integrated with our in-house preprocessing tool [QClus](https://www.github.com/linnalab/QClus.git) and possibly some other tools.

## Usage

### Step 1: Verify FASTQ Files

First, verify the integrity of your FASTQ files using the `md5_checks.sh` script.

#### Usage

```bash
./md5_checks.sh <directory_with_files> <md5_filename>
```

#### Example

```bash
./md5_checks.sh /path/to/fastq/files MD5.txt
```

This script will read the MD5 checksums from the specified file and compare them to the actual checksums of the files in the directory, reporting any discrepancies.

### Step 2: Configure and Run `process_sublibs.sh`

#### 2.1 Configure the Script

Open the `process_sublibs.sh` script in a text editor and modify the user-defined arguments at the top of the script to match your data and environment.

**User-Defined Arguments:**

```bash
# Base directory containing raw data sublibrary directories
RAW_DATA_BASE="/path/to/raw_data_base"

# List of sublibrary directories to process (full paths)
SUBLIB_DIRS=(
    "$RAW_DATA_BASE/Sub1"
    "$RAW_DATA_BASE/Sub2"
    # Add or remove sublibraries as needed
)

# Path to the sample list file (single file for all sublibraries)
SAMPLE_LIST="/path/to/sample-list.txt"

# Genome directory for Split-pipe
GENOME_DIR="/path/to/genome_directory"

# Output base directory for Split-pipe outputs
OUTPUT_BASE_DIR="/path/to/output_directory"

# Chemistry version (e.g., "v3")
CHEMISTRY="v3"

# Dry run option ("yes" for dry run, "no" for actual run)
DRY_RUN="no"

# Job configuration
TIME="6:00:00"     # Job time limit
MEMORY="32G"       # Memory per CPU
CPUS="8"           # Number of CPUs
```

- **RAW_DATA_BASE**: The base directory where your raw data sublibrary directories are located.
- **SUBLIB_DIRS**: An array of the full paths to each sublibrary directory you wish to process.
- **SAMPLE_LIST**: The path to your sample list file, which lists the samples to be processed.
- **GENOME_DIR**: The path to the genome directory used by Split-pipe.
- **OUTPUT_BASE_DIR**: The base output directory where the results will be stored.
- **CHEMISTRY**: The chemistry version of your experiment (e.g., "v3").
- **DRY_RUN**: Set to `"yes"` to perform a dry run without actual processing, or `"no"` to run the actual pipeline.
- **Job Configuration**: Adjust the job `TIME`, `MEMORY`, and `CPUS` requirements as needed.

#### 2.2 Run the Script

Make sure the script is executable:

```bash
chmod +x process_sublibs.sh
```

Run the script:

```bash
./process_sublibs.sh
```

This script will:

- Loop over each specified sublibrary directory.
- Concatenate multiple FASTQ files within each sublibrary if necessary.
- Submit a job for each sublibrary to process it using Split-pipe.

### Step 3: Monitor Job Progress

Monitor the output and error files generated in the output directories for each sublibrary to ensure that the jobs are running successfully.

- **Output Files**: Located in the output directory specified, named as `split_pipe_<SUBLIB_NAME>.<JOB_ID>.out`.
- **Error Files**: Located in the output directory specified, named as `split_pipe_<SUBLIB_NAME>.<JOB_ID>.err`.

You can also check the status of your jobs using:

```bash
squeue -u your_username
```

### Step 4: Combine Sublibraries

After all sublibraries have been processed, combine the results using the `combine_sublibs.sh` script.

#### 4.1 Create the Sublibraries List File

Create a text file (e.g., `sublibs.lis`) that lists the paths to the output directories of the processed sublibraries, one per line.

**Example `sublibs.lis`:**

```
/path/to/output/Sub1
/path/to/output/Sub2
# Add more sublibrary output directories as needed
```

#### 4.2 Configure the `combine_sublibs.sh` Script

Open `combine_sublibs.sh` and modify the user-defined arguments:

```bash
# Path to the manually created sublibraries list file
SUBLIB_LIST_FILE="/path/to/sublibs.lis"

# Output directory for combined results
COMBINED_OUTPUT_DIR="/path/to/output/combined_results"

# Job configuration
JOB_NAME="split_pipe_combine"
TIME="24:00:00"    # Job time limit
MEMORY="32G"       # Memory per CPU
CPUS="8"           # Number of CPUs

# Dry run option ("yes" for dry run, "no" for actual run)
DRY_RUN="no"
```

- **SUBLIB_LIST_FILE**: The path to your sublibraries list file.
- **COMBINED_OUTPUT_DIR**: The directory where the combined results will be stored.
- **Job Configuration**: Adjust the job `JOB_NAME`, `TIME`, `MEMORY`, and `CPUS` as needed.
- **DRY_RUN**: Set to `"yes"` to perform a dry run or `"no"` to run the actual combination.

#### 4.3 Run the Script

Make sure the script is executable:

```bash
chmod +x combine_sublibs.sh
```

Run the script:

```bash
./combine_sublibs.sh
```

This script will submit a job to combine the sublibrary results into a single dataset using Split-pipe.

### Step 5: Verify Combined Results

After the combination job completes, verify that the combined results are as expected.

- Check the output files in the combined results directory.
- Review any logs or reports generated by Split-pipe.

## Additional Notes

- **Error Handling**: If any errors occur, check the error logs in the output directories for troubleshooting.

- **Dry Run**: It's recommended to perform a dry run first by setting `DRY_RUN="yes"` to ensure that all configurations are correct before running the actual processing.

- **Data Backup**: Always keep a backup of your raw data and important files.



*For any questions or assistance, please open an issue or contact johannes.ojanen@gmail.com.*

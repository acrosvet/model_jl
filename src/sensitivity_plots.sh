#!/bin/bash
#SBATCH --ntasks=1
#SBATCH -p physical
#SBATCH --threads-per-core=1
#SBATCH --cpus-per-task=1
#SBATCH --time=1:00:00

Rscript sensitivity_analysis_batch.R

Rscript sensitivity_analysis_spring.R

Rscript sensitivity_analysis_split.R


#!/bin/bash
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH -p snowy
#SBATCH --threads-per-core=1
#SBATCH --cpus-per-task=16
#SBATCH --time=336:00:00
#SBATCH --mem=250G



module purge
module load julia/1.6.3

export JULIA_NUM_THREADS=16

julia /data/gpfs/projects/punim0549/acrosbie/model_main/sensitivity_split.jl



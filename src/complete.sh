#!/bin/bash
#SBATCH --ntasks=1
#SBATCH -p physical
#SBATCH --threads-per-core=1
#SBATCH --cpus-per-task=16
#SBATCH --time=100:10:00
#SBATCH --mem=350G

module purge
module load julia/1.6.3

export JULIA_NUM_THREADS=16

julia /data/gpfs/projects/punim0549/acrosbie/model_main/farm_na.jl


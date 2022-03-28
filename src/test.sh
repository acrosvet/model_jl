#!/bin/bash
#SBATCH --ntasks=1
#SBATCH -p physical
#SBATCH --threads-per-core=1
#SBATCH --cpus-per-task=8
#SBATCH --time=1:10:00
#SBATCH --mem 250G

module purge
module load julia/1.6.3


julia --threads 8 /data/gpfs/projects/punim0549/acrosbie/model_main/farm_na.jl


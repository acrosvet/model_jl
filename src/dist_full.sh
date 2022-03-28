#!/bin/bash
#SBATCH --ntasks=1
#SBATCH -p long
#SBATCH --threads-per-core=1
#SBATCH --cpus-per-task=2
#SBATCH --time=750:10:00
#SBATCH --mem 250G

module purge
module load julia/1.6.3


julia --threads 2 /data/gpfs/projects/punim0549/acrosbie/model_main/farm_na.jl

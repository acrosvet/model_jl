#!/bin/bash
#SBATCH -p physical
#SBATCH --time=06:30:00
#SBATCH --ntasks=8
#SBATCH --mem 1000G
#SBATCH --hint=multithread



module purge
module load julia/1.6.3
julia  --threads 16 /data/gpfs/projects/punim0549/acrosbie/model_main/run.jl









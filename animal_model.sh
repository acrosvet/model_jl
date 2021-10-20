#!/bin/bash
#SBATCH -p physical
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16


module purge
module load julia/1.6.3
julia --threads 16 /data/gpfs/projects/punim0549/acrosbie/model_jl/scratchpad.jl









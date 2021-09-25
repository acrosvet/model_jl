#!/bin/bash
#SBATCH -p physical
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8


module purge
module load julia/1.5.1-linux-x86_64
julia --threads 8 /data/gpfs/projects/punim0549/acrosbie/model_jl/scratchpad_farm.jl









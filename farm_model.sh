#!/bin/bash
#SBATCH -p physical
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16


module purge
module load julia/1.5.1-linux-x86_64
julia --threads 16 /data/gpfs/projects/punim0549/acrosbie/model_jl/scratchpad_farm.jl









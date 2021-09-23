#!/bin/bash
#SBATCH -p physical
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mail-user=acrosbie@student.unimelb.edu.au
#SBATCH --mail-type=ALL

module purge
module load julia/1.5.1-linux-x86_64
julia /data/gpfs/projects/punim0549/acrosbie/julia_abm/model_jl/hpc_run.jl









#!/bin/bash
#SBATCH -p physical
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1


module purge
module load julia/1.6.3
julia   /data/gpfs/projects/punim0549/acrosbie/model_jl_spring_mt/src/run.jl









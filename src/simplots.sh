#!/bin/bash
#SBATCH -p snowy
#SBATCH --time=00:20:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=25G


module purge
module load julia/1.6.3
julia   /data/gpfs/projects/punim0549/acrosbie/model_main/simplots.jl









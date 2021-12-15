#!/bin/bash
#SBATCH -p physical
#SBATCH --time=05:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=200000


module purge
module load julia/1.6.3
julia  --threads 32 /data/gpfs/projects/punim0549/acrosbie/model/spring_fpt.jl









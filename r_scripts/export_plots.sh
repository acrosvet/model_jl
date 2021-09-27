#!/bin/bash
#SBATCH -p physical
#SBATCH --time=00:20:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1


module purge
module load r/4.0.0 
r --vanilla /data/gpfs/projects/punim0549/acrosbie/model_jl/export_plots.r






#scp -r /home/alex/Documents/julia_abm/model_jl/ acrosbie@spartan.hpc.unimelb.edu.au:/data/gpfs/projects/punim0549/acrosbie

rsync -av --exclude='.git' --exclude='.vscode' --exclude='/export' /home/alex/Documents/julia_abm/model_jl/  acrosbie@spartan.hpc.unimelb.edu.au:/data/gpfs/projects/punim0549/acrosbie/model_jl
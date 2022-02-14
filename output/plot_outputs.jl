#Generate plot outputs for large-scale HPC runs

#Load packages

using(Plots)
using(JLD2)

#Import the file
@load "./output/vacc_1000.jld2"

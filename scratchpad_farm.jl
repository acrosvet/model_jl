using Distributed 

addprocs(16)

include("testing.jl")

include("farm_model.jl")

tmp = initialiseSeasonal(220)

include("aanimal_headers.jl")

#@time run!(tmp, agent_step!, model_step!, 365) 

tmp = initialiseFarms(farm_step!, 365)

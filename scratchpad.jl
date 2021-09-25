using Distributed 

addprocs(16)

include("testing.jl")

tmp = initialiseSeasonal(220)

include("aanimal_headers.jl")

@time run!(tmp, agent_step!, model_step!, 365) 


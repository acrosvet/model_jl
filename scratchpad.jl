using Distributed 

addprocs(5)

include("testing.jl")

tmp = initialiseSeasonal(220, nbact = 1000)

include("aanimal_headers.jl")

@time run!(tmp, agent_step!, model_step!, 5) 


using Distributed 

addprocs(5)

include("testing.jl")

tmp = initialiseSeasonal(100, nbact = 100, dims = 10, farm_id = 1, farm_status = :R, seed = 42)

include("aanimal_headers.jl")

@time run!(tmp, agent_step!, model_step!, 365) 


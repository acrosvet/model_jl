using Distributed 

addprocs(32)

include("testing.jl")


    tmp = initialiseSeasonal(25, nbact = 1000, dims = 33, farm_id = 1, farm_status = :R, seed = 42)


    include("aanimal_headers.jl")

    @time run!(tmp, agent_step!, model_step!, 25) 


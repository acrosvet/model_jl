using Distributed 

addprocs(32)

include("testing.jl")

<<<<<<< HEAD
tmp = initialiseSeasonal(100, nbact = 1000, dims = 33, farm_id = 1, farm_status = :R, seed = 42)


=======
tmp = initialiseSeasonal(100, nbact = 100, dims = 10, farm_id = 1, farm_status = :R, seed = 42)
>>>>>>> parent of 069de04 (push)

include("aanimal_headers.jl")

@time run!(tmp, agent_step!, model_step!, 365) 


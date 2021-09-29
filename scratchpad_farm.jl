using Distributed 

addprocs(16)

include("testing.jl")

include("farm_model.jl")

#tmp = initialiseSeasonal(220)

include("aanimal_headers.jl")
include("trade_header.jl")

#@time run!(tmp, agent_step!, model_step!, 365) 

tmp = initialiseFarms(numfarms = 50, nbact = 10000, dim = 100)

@time run!(tmp, farm_step!, farm_mstep!, 50)
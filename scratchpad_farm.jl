using Distributed 

addprocs(16)

 include("testing.jl")



 include("farm_model.jl")        

#tmp = initialiseSeasonal(220)

 include("aanimal_headers.jl")
 include("trade_header.jl")

 tmp = initialiseFarms(numfarms = 100, nbact = 1000, dims = 33)

@time run!(tmp, farm_step!, farm_mstep!, 365)

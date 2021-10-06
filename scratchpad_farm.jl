using Distributed 

addprocs(32)
include("testing.jl")



include("farm_model.jl")        

#tmp = initialiseSeasonal(220)

include("aanimal_headers.jl")
include("trade_header.jl")

#@time run!(tmp, agent_step!, model_step!, 365) 

#= Threads.@threads for i in 1:Threads.nthreads()
    #println(i)
        # We use a different seed for each thread so that the various threads don't duplicate
        # the same values.
        Random.seed!(1234 + i)
end
 =#
tmp = initialiseFarms(numfarms = 100, nbact = 1000, dims = 33)

@time run!(tmp, farm_step!, farm_mstep!, 100)
println(Threads.nthreads())
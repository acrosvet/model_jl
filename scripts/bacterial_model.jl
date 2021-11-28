include("./src/bacterial.jl")
using .bacterial

using Agents
using CSV
using DataFrames
using Distributions
using Dates
using Random
using DrWatson

@time bactoMod = initialiseBacteria(nbact = 1000, dims = 33, total_status = :S, timestep = 1.0, age = 0, days_treated = 0, days_exposed = 0, days_recovered = 0, stress = false, animalno = 0)

bact_export_headers()
@time run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_exposed = 1
bactoMod.total_status = :ER
@time run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_exposed = 0
run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 1
run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 2
run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 3
run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 0
bactoMod.total_status = :recovered
bactoMod.days_recovered = 1
run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 0
bactoMod.days_recovered = 2
run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 0
bactoMod.days_recovered = 3
run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 0
bactoMod.days_recovered = 4
run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 0
bactoMod.days_recovered = 5
run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 0
bactoMod.days_recovered = 6
run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 0
bactoMod.days_recovered = 7
run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 0
bactoMod.days_recovered = 8
run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 0
bactoMod.days_recovered = 9
run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 0
bactoMod.days_recovered = 10
run!(bactoMod, bact_agent_step!, bact_model_step!, 20)
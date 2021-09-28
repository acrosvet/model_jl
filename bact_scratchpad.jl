include("packages.jl")
include("agent_types.jl")
include("abm_bacterial.jl")
include("bact_agent_step.jl")
include("bact_model_step.jl")
include("bacterial_population.jl")
include("bacterial_treatment.jl")
include("bact_infection.jl")
include("bact_fitness.jl")
include("bact_plasmid_transfer.jl")
include("bact_empty_neighbours.jl")
include("bact_treatment_response.jl")
include("export_bacterial_position.jl")
include("export_bacterial_data.jl")
include("bact_invasion.jl")
include("bact_recovery.jl")
include("bact_carrier_state.jl")
include("bact_stressor.jl")
include("bact_infected_transition.jl")

@time bactoMod = initialiseBacteria(nbact = 10000, total_status = :IR, timestep = 1.0, age = 0, days_treated = 0, days_exposed = 0, days_recovered = 0, stress = false, animalno = 0)

include("bact_export_headers.jl")
@time run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_exposed = 1
@time run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_exposed = 0
run!(bactoMod, bact_agent_step!, bact_model_step!, 5)

bactoMod.days_treated = 1
run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 2
run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 3
run!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 0
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
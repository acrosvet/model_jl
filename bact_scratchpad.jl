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


bactoMod = initialisePopulation(nbact = 1000, total_status = :S, timestep = 1.0, age = 0, days_treated = 0, days_exposed = 0)

include("bact_export_headers.jl")
@time run!(bactoMod, bact_agent_step!, bact_model_step!, 100)

@time step!(bactoMod, bact_agent_step!, bact_model_step!,1)

bactoMod.days_treated = 1

step!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 2

step!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 3

step!(bactoMod, bact_agent_step!, bact_model_step!, 1)

bactoMod.days_treated = 0

step!(bactoMod, bact_agent_step!, bact_model_step!, 10)
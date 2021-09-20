include("packages.jl")
include("agent_types.jl")
include("abm_bacterial.jl")
include("bact_agent_step.jl")
include("bact_export_headers.jl")
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

run!(bactoMod, bact_agent_step!, bact_model_step!, 35)
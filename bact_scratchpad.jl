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


bactoMod = initialisePopulation(nbact = 10000, total_status = :ES, timestep = 1.0, age = 0, days_treated = 0, days_exposed = 0)

include("bact_export_headers.jl")
@time run!(bactoMod, bact_agent_step!, bact_model_step!, 100)

for i in 1:50
    
    if i == 10
        bactoMod.days_treated = 1
    end

    if i == 14
        bactoMod.days_treated = 0
    end

    step!(bactoMod, bact_agent_step!, bact_model_step!, i)
end
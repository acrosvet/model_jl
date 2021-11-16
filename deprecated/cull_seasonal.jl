function cull_seasonal!(AnimalAgent, animalModel, current_lactating)

if animalModel.system == :Seasonal
    
    if current_lactating > animalModel.num_lac 
        if AnimalAgent.age ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(7*365), 2*365, 7*365))))
            if haskey(animalModel.agents, AnimalAgent.id)
                culling_reason = "Age"
                export_culling!(AnimalAgent, animalModel, culling_reason)
                kill_agent!(AnimalAgent, animalModel)
            end
        end
    end

    if current_lactating > animalModel.num_lac 
        if AnimalAgent.stage == :L && (AnimalAgent.dim ≥ 280 && AnimalAgent.dic < 150)
            if haskey(animalModel.agents, AnimalAgent.id)
                culling_reason = "Fertility"
                export_culling!(AnimalAgent, animalModel, culling_reason)
                kill_agent!(AnimalAgent, animalModel)
            end
        end
    end 
    
end
end 
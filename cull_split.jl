function cull_split!(AnimalAgent, animalModel, current_lactating)

# Split calving systems ---------------------------------------------------
if animalModel.system  == :Split


    current_spring = [a.stage == :L && a.calving_season == :Spring for a in allagents(animalModel)]
    current_spring = sum(current_spring)
    animalModel.current_spring = current_spring
    
    current_autumn = [a.stage == :L && a.calving_season == :Autumn for a in allagents(animalModel)]
    current_autumn = sum(current_autumn)
    animalModel.current_autumn = current_autumn
    
    if current_lactating > animalModel.num_lac 
        if AnimalAgent.calving_season == :Spring 
            if current_spring > animalModel.lac_spring
                if AnimalAgent.age ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(7*365), 2*365, 7*365))))
                    if haskey(animalModel.agents, AnimalAgent.id)
                        culling_reason = "Age"
                        export_culling!(AnimalAgent, animalModel, culling_reason)
                        kill_agent!(AnimalAgent, animalModel)
                    end
                end
            end 
        end

        if AnimalAgent.calving_season == :Spring
            if current_spring > animalModel.lac_spring
                if AnimalAgent.stage == :L && (AnimalAgent.dim ≥ 280 && AnimalAgent.dic < 150)
                    if haskey(animalModel.agents, AnimalAgent.id)
                        if AnimalAgent.agenttype != :CO
                            culling_reason = "Fertility"
                            export_culling!(AnimalAgent, animalModel, culling_reason)
                            kill_agent!(AnimalAgent, animalModel)
                        end
                    end
                end
            end 
        end
        ################################
        if AnimalAgent.calving_season == :Autumn 
            if current_autumn > animalModel.lac_autumn
                if AnimalAgent.age ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(7*365), 2*365, 7*365))))
                    if haskey(animalModel.agents, AnimalAgent.id)
                        culling_reason = "Age"
                        export_culling!(AnimalAgent, animalModel, culling_reason)
                        kill_agent!(AnimalAgent, animalModel)
                    end
                end
            end 
        end

        if AnimalAgent.calving_season == :Autumn
            if current_autumn > animalModel.lac_autumn
                if AnimalAgent.stage == :L && (AnimalAgent.dim ≥ 280 && AnimalAgent.dic < 150)
                    if AnimalAgent.agenttype != :CO
                        if haskey(animalModel.agents, AnimalAgent.id)
                            culling_reason = "Fertility"
                            export_culling!(AnimalAgent, animalModel, culling_reason)
                            kill_agent!(AnimalAgent, animalModel)
                        end
                    end
                end
            end 
        end

    end
end 

end
function cull_batch!(AnimalAgent, animalModel, current_lactating)

# Batch calving systems -----------------------------------------------------------------

if animalModel.system  == :Batch


    current_b1= [a.stage == :L && a.calving_season == :B1 for a in allagents(animalModel)]
    current_b1 = sum(current_b1)
    animalModel.current_b1 = current_b1

    current_b2= [a.stage == :L && a.calving_season == :B2 for a in allagents(animalModel)]
    current_b2 = sum(current_b2)
    animalModel.current_b2 = current_b2

    current_b3 = [a.stage == :L && a.calving_season == :B3 for a in allagents(animalModel)]
    current_b3 = sum(current_b3)
    animalModel.current_b3 = current_b3

    current_b4= [a.stage == :L && a.calving_season == :B4 for a in allagents(animalModel)]
    current_b4 = sum(current_b4)
    animalModel.current_b4 = current_b4
    
    if current_lactating > animalModel.num_lac 

    # Batch 1 ---------------------------------------------    
        if AnimalAgent.calving_season == :B1
            if current_b1 > animalModel.lac_batch
                if AnimalAgent.age ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(7*365), 2*365, 7*365))))
                    if haskey(animalModel.agents, AnimalAgent.id)
                        culling_reason = "Age"
                        export_culling!(AnimalAgent, animalModel, culling_reason)
                        kill_agent!(AnimalAgent, animalModel)
                    end
                end
            end 
        end

        if AnimalAgent.calving_season == :B1
            if current_b1 > animalModel.lac_batch
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
    
    # Batch 2 --------------------------------------------------------------------
  
    if AnimalAgent.calving_season == :B2
        if current_b2 > animalModel.lac_batch
            if AnimalAgent.age ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(7*365), 2*365, 7*365))))
                if haskey(animalModel.agents, AnimalAgent.id)
                    culling_reason = "Age"
                    export_culling!(AnimalAgent, animalModel, culling_reason)
                    kill_agent!(AnimalAgent, animalModel)
                end
            end
        end 
    end

    if AnimalAgent.calving_season == :B2
        if current_b2 > animalModel.lac_batch
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

    # Batch 3 ---------------------------------------------    
    if AnimalAgent.calving_season == :B3
        if current_b3 > animalModel.lac_batch
            if AnimalAgent.age ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(7*365), 2*365, 7*365))))
                if haskey(animalModel.agents, AnimalAgent.id)
                    culling_reason = "Age"
                    export_culling!(AnimalAgent, animalModel, culling_reason)
                    kill_agent!(AnimalAgent, animalModel)
                end
            end
        end 
    end

    if AnimalAgent.calving_season == :B3
        if current_b3 > animalModel.lac_batch
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

    # Batch 4 ---------------------------------------------    
    if AnimalAgent.calving_season == :B4
        if current_b4 > animalModel.lac_batch
            if AnimalAgent.age ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(7*365), 2*365, 7*365))))
                if haskey(animalModel.agents, AnimalAgent.id)
                    culling_reason = "Age"
                    export_culling!(AnimalAgent, animalModel, culling_reason)
                    kill_agent!(AnimalAgent, animalModel)
                end
            end
        end 
    end

    if AnimalAgent.calving_season == :B4
        if current_b4 > animalModel.lac_batch
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

    end
end 

end
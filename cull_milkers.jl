"""
**cull_milkers!(AnimalAgent, animalModel)

* Cull milkers as a result of repro performance or age

"""

function cull_milkers!(AnimalAgent, animalModel)




#println("The number of agents is $num_agents")
if AnimalAgent.stage == :D && AnimalAgent.pregstat == :E
    if haskey(animalModel.agents, AnimalAgent.id)
        culling_reason = "Empty dry"
        export_culling!(AnimalAgent, animalModel, culling_reason)
        kill_agent!(AnimalAgent, animalModel)
    end
end

if AnimalAgent.dic >= 320
    if haskey(animalModel.agents, AnimalAgent.id)
        culling_reason = "Slipped"
        export_culling!(AnimalAgent, animalModel, culling_reason)
        kill_agent!(AnimalAgent, animalModel)
    end
end




container = [a.stage == :L for a in allagents(animalModel)]
current_lactating = sum(container)

animalModel.current_lac = current_lactating

# Spring calving systems -------------------------------------------------

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

# Continuous calving systems -------------------------------------------

if animalModel.system == :Continuous
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
        if AnimalAgent.stage == :L && (AnimalAgent.dim ≥ 300 && AnimalAgent.dic < 150)
            if haskey(animalModel.agents, AnimalAgent.id)
                culling_reason = "Fertility"
                export_culling!(AnimalAgent, animalModel, culling_reason)
                kill_agent!(AnimalAgent, animalModel)
            end
        end
    end 
end

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
"""
**cull_milkers!(AnimalAgent, animalModel)

* Cull milkers as a result of repro performance or age

"""

function cull_milkers!(AnimalAgent, animalModel)

current_spring = [a.stage == :L && a.calving_season == :Spring for a in allagents(animalModel)]
current_spring = sum(current_spring)
animalModel.current_spring = current_spring

current_autumn = [a.stage == :L && a.calving_season == :Autumn for a in allagents(animalModel)]
current_autumn = sum(current_autumn)
animalModel.current_autumn = current_autumn




#println("The number of agents is $num_agents")
if AnimalAgent.stage == :D && AnimalAgent.pregstat == :E
    if haskey(animalModel.agents, AnimalAgent.id)
        kill_agent!(AnimalAgent, animalModel)
        println("Culled empty dry")
    end
end

if AnimalAgent.dic >= 320
    if haskey(animalModel.agents, AnimalAgent.id)
        kill_agent!(AnimalAgent, animalModel)
        println("Slipped, cull")
    end
end




container = [a.stage == :L for a in allagents(animalModel)]
current_lactating = sum(container)

animalModel.current_lac = current_lactating

if current_lactating > animalModel.num_lac 
    if AnimalAgent.calving_season == :Spring 
        if current_spring > animalModel.lac_spring
            if AnimalAgent.age ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(7*365), 2*365, 7*365))))
                if haskey(animalModel.agents, AnimalAgent.id)
                    kill_agent!(AnimalAgent, animalModel)
                    println("Age cull")
                end
            end
        end 
    end

    if AnimalAgent.calving_season == :Spring
        if current_spring > animalModel.lac_spring
            if AnimalAgent.stage == :L && (AnimalAgent.dim ≥ 280 && AnimalAgent.dic < 150)
                if haskey(animalModel.agents, AnimalAgent.id)
                    if AnimalAgent.agenttype != :CO
                        kill_agent!(AnimalAgent, animalModel)
                        println("Fertility cull")
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
                    kill_agent!(AnimalAgent, animalModel)
                    println("Age cull")
                end
            end
        end 
    end

    if AnimalAgent.calving_season == :Autumn
        if current_autumn > animalModel.lac_autumn
            if AnimalAgent.stage == :L && (AnimalAgent.dim ≥ 280 && AnimalAgent.dic < 150)
                if AnimalAgent.agenttype != :CO
                    if haskey(animalModel.agents, AnimalAgent.id)
                        kill_agent!(AnimalAgent, animalModel)
                        println("Fertility cull")
                    end
                end
            end
        end 
    end

end

end
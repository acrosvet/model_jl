"""
**cull_milkers!(AnimalAgent, animalModel)

* Cull milkers as a result of repro performance or age

"""

function cull_milkers!(AnimalAgent, animalModel)


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


 if animalModel.current_lac > animalModel.num_lac
    if AnimalAgent.age ≥ rand(animalModel.rng, truncated(Poisson(7*365), 2*365, 7*365))
        if haskey(animalModel.agents, AnimalAgent.id)
        kill_agent!(AnimalAgent, animalModel)
        println("Age cull")
        end
    end
end 

if animalModel.current_lac > animalModel.num_lac
    if AnimalAgent.stage == :L && (AnimalAgent.dim ≥ 280 && AnimalAgent.dic < 150)
        if haskey(animalModel.agents, AnimalAgent.id)
            kill_agent!(AnimalAgent, animalModel)
            println("Fertility cull")
        end
    end
end 


end
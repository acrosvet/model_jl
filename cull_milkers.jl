"""
**cull_milkers!(AnimalAgent, animalModel)

* Cull milkers as a result of repro performance or age

"""

function cull_milkers!(AnimalAgent, animalModel)

    function current_stock(animalModel, stage)
        counter = 0
        for i in 1:length(animalModel.agents)
            if (haskey(animalModel.agents, i) == true) && animalModel.agents[i].stage == stage
                counter += 1
            end
        end
        return counter

    end

if AnimalAgent.stage == :D && AnimalAgent.pregstat == :E
    kill_agent!(AnimalAgent, animalModel)
    println("Culled empty dry")
end

if AnimalAgent.dic >= 320
    kill_agent!(AnimalAgent, animalModel)
    println("Slipped, cull")
end

current_lactating = current_stock(animalModel, :L)

#= if current_lactating > animalModel.num_lac
    if AnimalAgent.stage == :L 
        if haskey(animalModel.agents, AnimalAgent.id)
            kill_agent!(AnimalAgent, animalModel)
            println("Fertility cull")
        end
    end
end  =#
#= 
 if current_lactating > animalModel.num_lac 
    if AnimalAgent.age in rand(animalModel.rng, truncated(Poisson(7*365), 2*365, 7*365), 1000)
        kill_agent!(AnimalAgent, animalModel)
        println("Age cull")
    end
end 
 =#
 #println(current_lactating)


 
#=     if AnimalAgent.stage == :L && AnimalAgent.dim ≥ 280
        if AnimalAgent.pregstat == :E
                kill_agent!(AnimalAgent, animalModel)
                println("Fertility cull")
        
    #=     elseif AnimalAgent.age ≥ rand(animalModel.rng, truncated(Poisson(7*365), 2*365, 9*365)) && AnimalAgent.dim ≥ 280
            if rand(animalModel.rng) > 0.5
                kill_agent!(AnimalAgent, animalModel)
                println("Age cull")
            end =#
        end
    end    
 =#
end
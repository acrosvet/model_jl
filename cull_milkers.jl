"""
**cull_milkers!(AnimalAgent, animalModel)

* Cull milkers as a result of repro performance or age

"""

function cull_milkers!(AnimalAgent, animalModel)

if AnimalAgent.stage == :D && AnimalAgent.pregstat == :E
    kill_agent!(AnimalAgent, animalModel)
    println("Culled empty dry")
end

if AnimalAgent.dic >= 320
    kill_agent!(AnimalAgent, animalModel)
    println("Slipped, cull")
end
    
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
"""
**cull_milkers!(AnimalAgent, animalModel)

* Cull milkers as a result of repro performance or age

"""

function cull_milkers!(AnimalAgent, animalModel)

if AnimalAgent.stage == :L && AnimalAgent.dim ≥ 280
    if AnimalAgent.pregstat == :E
        if animalModel.date ≥ (animalModel.msd + Day(12*7))
            kill_agent!(AnimalAgent, animalModel)
            println("Fertility cull")
        end
    
    elseif AnimalAgent.age ≥ rand(animalModel.rng, truncated(Poisson(7*365), 2*365, 9*365)) && AnimalAgent.dim ≥ 280
        kill_agent!(AnimalAgent, animalModel)
        println("Age cull")
    end
end    

end
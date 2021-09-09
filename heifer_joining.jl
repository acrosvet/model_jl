"""
**heifer_joining!(AnimalAgent, animalModel)**

* Join heifers

"""

function heifer_joining!(AnimalAgent, animalModel)
    
    if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
        if (animalModel.date ≥ (animalModel.msd - Day(21))) && (animalModel.date ≤ (animalModel.msd + Day(9*7)))
            #if (AnimalAgent.age - 13*30 % 21 == 0)
            if (Dates.value(animalModel.date - (animalModel.msd - Day(21)))) == rand(animalModel.rng, truncated(Poisson(10), 21, 12*7))
                #if rand(animalModel.rng) > 0.5
                    AnimalAgent.pregstat = :P
                    AnimalAgent.dic = 1
                    AnimalAgent.stage = :DH
                    println("Heifer joined")
                #end
            end
        end   

    end
  
if AnimalAgent.stage == :H && AnimalAgent.age >= 700
    if AnimalAgent.pregstat == :E
        kill_agent!(AnimalAgent, animalModel)
        println("Empty heifer cull")
    end
end

end

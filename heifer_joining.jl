"""
**heifer_joining!(AnimalAgent, animalModel)**

* Join heifers

"""

function heifer_joining!(AnimalAgent, animalModel)
    if AnimalAgent.stage == :H
        if (animalModel.date ≥ (animalModel.msd - Day(21))) && (animalModel.date ≤ (animalModel.msd + Day(9*7)))
            #if (AnimalAgent.age - 13*30 % 21 == 0)
            if (Dates.value(animalModel.date - (animalModel.msd - Day(21))) % 21) == 0
                if rand(animalModel.rng) > 0.5
                    AnimalAgent.pregstat = :P
                    AnimalAgent.dic = 1
                    AnimalAgent.stage = :DH
                    println("Heifer joined")
                end
            end   
        elseif  animalModel.date > (animalModel.msd + Day(15*7)) && AnimalAgent.pregstat == :E
            kill_agent!(AnimalAgent, animalModel)
            println("Empty heifer cull")
        end
    end
  
end

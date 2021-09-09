"""
**heifer_joining!(AnimalAgent, animalModel)

* Join heifers

"""

function heifer_joining!(AnimalAgent, animalModel)
    if AnimalAgent.stage == :H
        if (animalModel.date ≥ (animalModel.msd - Day(21))) && (animalModel.date ≤ (animalModel.msd + Day(9*7)))
            if animalModel.day % (animalModel.msd - Day(21)) == 0
                if rand(animalModel.rng) > 0.5
                    animal.pregstat = :P
                    animal.dic = 1
                end
            end   
    end
end
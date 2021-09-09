"""
**heifer!(AnimalAgent, animalModel)** \n 

* Age animals from weaned to heifer based on msd

"""

function heifer!(AnimalAgent, animalModel)

    if AnimalAgent.status == :W
        if animalModel.date ≥ (animalModel.msd - Day(21))
            AnimalAgent.status = :H
        end
    end

end
"""
**heifer!(AnimalAgent, animalModel)** \n 

* Age animals from weaned to heifer based on msd

"""

function heifer!(AnimalAgent, animalModel)

    if AnimalAgent.age ≥ 15*(365/12) && AnimalAgent.stage == :W
        AnimalAgent.stage = :H
    end


end
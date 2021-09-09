"""
**heifer!(AnimalAgent, animalModel)** \n 

* Age animals from weaned to heifer based on msd

"""

function heifer!(AnimalAgent, animalModel)

    if AnimalAgent.age ≥ 13*(365/12) && AnimalAgent.stage == :C
        AnimalAgent.stage = :H
    end


end
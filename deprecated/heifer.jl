"""
**heifer!(AnimalAgent, animalModel)** \n 

* Age animals from weaned to heifer based on msd

"""

function heifer!(AnimalAgent, animalModel)

    
    if AnimalAgent.age ≥ 13*30 && AnimalAgent.stage == :W
        AnimalAgent.stage = :H
        higher_dimension!(AnimalAgent, animalModel, stage = :H, level = 3, density = 7)
    end


end
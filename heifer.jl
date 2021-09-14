"""
**heifer!(AnimalAgent, animalModel)** \n 

* Age animals from weaned to heifer based on msd

"""

function heifer!(AnimalAgent, animalModel)

    if AnimalAgent.age ≥ 13*30 && AnimalAgent.stage == :W
        AnimalAgent.stage = :H
        AnimalAgent.pos = (rand(animalModel.rng, 1:100, 2)..., 3)
    end


end
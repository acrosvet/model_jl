"""
**heifer!(AnimalAgent, animalModel)** \n 

* Age animals from weaned to heifer based on msd

"""

function heifer!(AnimalAgent, animalModel)

    num_heifers = [a.stage == :H for a in allagents(animalModel)]
    num_heifers = sum(num_heifers)
    heifer_range = Int(floor(7*√num_heifers))

    if AnimalAgent.age ≥ 13*30 && AnimalAgent.stage == :W
        AnimalAgent.stage = :H
        pos = (rand(animalModel.rng, 1:heifer_range, 2)..., 3)
        while !isempty(pos, animalModel)
            pos = (rand(animalModel.rng, 1:heifer_range, 2)..., 3)
        end
        move_agent!(AnimalAgent, pos, animalModel)
    end


end
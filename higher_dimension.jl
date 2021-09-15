function higher_dimension!(AnimalAgent, animalModel; stage, level, density)

    stock = [a.stage == stage for a in allagents(animalModel)]
    stock = sum(stock)
    if stock == 0
        range = 10
    else
        range = Int(floor(density*√stock))
    end 

    pos = (rand(animalModel.rng, 1:range, 2)..., level)
    while !isempty(pos, animalModel)
        pos = (rand(animalModel.rng, 1:range, 2)..., level)
    end
    if haskey(animalModel.agents, AnimalAgent.id)
        move_agent!(AnimalAgent, pos, animalModel)
    end
end
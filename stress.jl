function stress!(AnimalAgent, animalModel)

    # Define times of stress in which carrier animals are likely to shed, animals in the periparturient period.

    if AnimalAgent.dim == rand(animalModel.rng, 0:60) || AnimalAgent.dic == rand(animalModel.rng, 270:283)
        AnimalAgent.stress = true
    else
        AnimalAgent.stress = false
    end

end
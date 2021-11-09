function dryoff_seasonal!(AnimalAgent, animalModel)
# Spring calving system -------------------------------------------------------------
if animalModel.system == :Seasonal|| animalModel.system == :Continuous
    if AnimalAgent.dim ≥ rand(animalModel.rng, 290:315)
            AnimalAgent.stage = :D
            AnimalAgent.days_dry = 1
            AnimalAgent.dim = 0
            higher_dimension!(AnimalAgent, animalModel, stage = :D, level = 6, density = 7)

    end
end


end
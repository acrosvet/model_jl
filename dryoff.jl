"""
**dryoff!(AnimalAgent)
"""
function dryoff!(AnimalAgent, animalModel)

    if AnimalAgent.dim ≥ rand(animalModel.rng, truncated(Poisson(305), 290, 330))
        AnimalAgent.stage = :D
        AnimalAgent.days_dry = 1
    end
end
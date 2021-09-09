"""
**wean!(AnimalAgent)** \n

* Wean animal agents to weaned status
* Between 55 and 70 days if status is calf

"""
function wean!(AnimalAgent, animalModel)
    if AnimalAgent.stage == :C
        if AnimalAgent.age ≥ rand(animalModel.rng, truncated(Poisson(60), 55, 70))
            AnimalAgent.stage = :W
        end
    end
end
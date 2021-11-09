"""
**wean!(AnimalAgent)** \n

* Wean animal agents to weaned status
* Between 55 and 70 days if status is calf

"""
function wean!(AnimalAgent, animalModel)

# Wean calves at between 55 and 70 days of age

    if AnimalAgent.stage == :C
        #if AnimalAgent.age ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(60), 55, 70))))
        if AnimalAgent.age ≥ rand(animalModel.rng, 55:70)

            if rand(animalModel.rng) < 0.5
                AnimalAgent.stage = :W
                higher_dimension!(AnimalAgent, animalModel, stage = :W, level = 2, density = 7)
            else
                culling_reason = "Surplus"
                export_culling!(AnimalAgent, animalModel, culling_reason)
                kill_agent!(AnimalAgent, animalModel)
            end 
        end
    end



end
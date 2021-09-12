"""
**wean!(AnimalAgent)** \n

* Wean animal agents to weaned status
* Between 55 and 70 days if status is calf

"""
function wean!(AnimalAgent, animalModel)
    if AnimalAgent.stage == :C
        if AnimalAgent.age ≥ rand(animalModel.rng, truncated(Rayleigh(60), 55, 70))
            
            if rand(animalModel.rng) < 0.5
                AnimalAgent.stage = :W
            else
                kill_agent!(AnimalAgent, animalModel)
                println("Surplus")
            end 
        end
    end
end
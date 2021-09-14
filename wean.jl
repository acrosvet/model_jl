"""
**wean!(AnimalAgent)** \n

* Wean animal agents to weaned status
* Between 55 and 70 days if status is calf

"""
function wean!(AnimalAgent, animalModel)
if animalModel.system != :Continuous
    if AnimalAgent.stage == :C
        if AnimalAgent.age ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(60), 55, 70))))
            
            if rand(animalModel.rng) < 0.5
                AnimalAgent.stage = :W
                AnimalAgent.pos[3] = 2
            else
                kill_agent!(AnimalAgent, animalModel)
                println("Surplus")
            end 
        end
    end
end

if animalModel.system == :Continuous
    if AnimalAgent.stage == :C
        if AnimalAgent.age ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(60), 55, 70))))
                AnimalAgent.stage = :W
                AnimalAgent.pos = (rand(animalModel.rng, 1:100, 2)...,2)
            end 
        end
    end
end
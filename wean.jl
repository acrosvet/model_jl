"""
**wean!(AnimalAgent)** \n

* Wean animal agents to weaned status
* Between 55 and 70 days if status is calf

"""
function wean!(AnimalAgent, animalModel)

    num_weaned = [a.stage == :W for a in allagents(animalModel)]
    num_weaned = sum(num_weaned)

    if num_weaned == 0
        weaned_range = 10
    else
        weaned_range = Int(floor(7*√num_weaned))
    end
    
if animalModel.system != :Continuous
    if AnimalAgent.stage == :C
        if AnimalAgent.age ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(60), 55, 70))))
            
            if rand(animalModel.rng) < 0.5
                AnimalAgent.stage = :W
                pos = (rand(animalModel.rng, 1:weaned_range, 2)..., 2)
                while !isempty(pos, animalModel)
                    pos = (rand(animalModel.rng, 1:weaned_range, 2)..., 2)
                end
                move_agent!(AnimalAgent, pos, animalModel)
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
                pos = (rand(animalModel.rng, 1:weaned_range, 2)..., 2)
                while !isempty(pos, animalModel)
                    pos = (rand(animalModel.rng, 1:weaned_range, 2)..., 2)
                end
                move_agent!(AnimalAgent, pos, animalModel)
            end 
        end
    end
end
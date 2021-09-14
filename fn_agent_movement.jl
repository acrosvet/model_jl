function agent_movement!(AnimalAgent, animalModel)

if AnimalAgent.stage == :C
    walk!(AnimalAgent, (rand(animalModel.rng(-10:10)), rand(animalModel.rng(-10:10)),0), animalModel; ifempty = false)
elseif AnimalAgent.stage == :W
elseif AnimalAgent.stage == :H
elseif AnimalAgent.stage == :DH
elseif AnimalAgent.stage == :L
elseif AnimalAgent.stage == :D
end

end
function agent_movement!(AnimalAgent, animalModel)

if AnimalAgent.stage == :C
    num_calves = [a.stage == :C for a in allagents(animalModel)]
    num_calves = sum(num_calves)
    if num_calves == 0
        calf_range = 10
    else
        calf_range = Int(floor(3*√num_calves))
    end 
    pos = (rand(animalModel.rng, 1:calf_range, 2)..., 1)
    while !isempty(pos, animalModel)
        pos = (rand(animalModel.rng, 1:calf_range, 2)..., 1)
    end
    move_agent!(AnimalAgent, pos, animalModel)
   # move_agent!(AnimalAgent, (rand(animalModel.rng, (0:calf_range)), rand(animalModel.rng, (0:calf_range)),0), animalModel; ifempty = false)
elseif AnimalAgent.stage == :W
elseif AnimalAgent.stage == :H
elseif AnimalAgent.stage == :DH
elseif AnimalAgent.stage == :L
elseif AnimalAgent.stage == :D
end

end
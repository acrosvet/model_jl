function agent_movement!(AnimalAgent, animalModel)

    Random.seed!(animalModel.rng)

if AnimalAgent.stage == :C

    num_calves = animalModel.current_calves
    if num_calves == 0
        calf_range = 10 
    else
        calf_range = Int(floor(3*√num_calves)) > 100 ? 100 : Int(floor(3*√num_calves))
    end 
    pos = (rand(animalModel.rng, 1:calf_range, 2)..., 1)
    while !isempty(pos, animalModel)
        pos = (rand(animalModel.rng, 1:calf_range, 2)..., 1)
    end
    move_agent!(AnimalAgent, pos, animalModel)
elseif AnimalAgent.stage == :W
        num_weaned = animalModel.current_weaned
#=     num_weaned = [a.stage == :W for a in allagents(animalModel)]
    num_weaned = sum(num_weaned) =#
    if num_weaned == 0
        weaned_range = 10
    else
        weaned_range = Int(floor(7*√num_weaned)) > 100 ? 100 : Int(floor(7*√num_weaned))
    end 
    pos = (rand(animalModel.rng, 1:weaned_range, 2)..., 2)
    while !isempty(pos, animalModel)
        pos = (rand(animalModel.rng, 1:weaned_range, 2)..., 2)
    end
    move_agent!(AnimalAgent, pos, animalModel)
elseif AnimalAgent.stage == :H
    num_heifers = animalModel.current_heifers
#=     num_heifers = [a.stage == :H for a in allagents(animalModel)]
    num_heifers = sum(num_heifers) =#
    if num_heifers == 0
        heifer_range = 10
    else
        heifer_range = Int(floor(7*√num_heifers)) > 100 ? 100 : Int(floor(7*√num_heifers))
    end 
    pos = (rand(animalModel.rng, 1:heifer_range, 2)..., 3)
    while !isempty(pos, animalModel)
        pos = (rand(animalModel.rng, 1:heifer_range, 2)..., 3)
    end
    move_agent!(AnimalAgent, pos, animalModel)
elseif AnimalAgent.stage == :DH
    num_dh = animalModel.current_dh
#=     num_dh = [a.stage == :DH for a in allagents(animalModel)]
    num_dh = sum(num_dh) =#
    if num_dh == 0
        dh_range = 10
    else
        dh_range = Int(floor(7*√num_dh)) > 100 ? 100 : Int(floor(7*√num_dh))
    end 
    pos = (rand(animalModel.rng, 1:dh_range, 2)..., 4)
    while !isempty(pos, animalModel)
        pos = (rand(animalModel.rng, 1:dh_range, 2)..., 4)
    end
    move_agent!(AnimalAgent, pos, animalModel)
elseif AnimalAgent.stage == :L
    num_lactating = animalModel.current_lac
#=     num_lactating = [a.stage == :L for a in allagents(animalModel)]
    num_lactating = sum(num_lactating) =#
    if num_lactating == 0
        lactating_range = 10
    else
        lactating_range = Int(floor(6*√num_lactating)) > 100 ? 100 : Int(floor(6*√num_lactating))
    end 
    pos = (rand(animalModel.rng, 1:lactating_range, 2)..., 5)
    while !isempty(pos, animalModel)
        pos = (rand(animalModel.rng, 1:lactating_range, 2)..., 5)
    end
    move_agent!(AnimalAgent, pos, animalModel)
elseif AnimalAgent.stage == :D
    num_dry = animalModel.current_dry
#=     num_dry = [a.stage == :D for a in allagents(animalModel)]
    num_dry = sum(num_dry) =#
    if num_dry == 0
        dry_range = 10
    else
        dry_range = Int(floor(3*√num_dry)) > 100 ? 100 : Int(floor(3*√num_dry)) 
    end 
    pos = (rand(animalModel.rng, 1:dry_range, 2)..., 6)
    while !isempty(pos, animalModel)
        pos = (rand(animalModel.rng, 1:dry_range, 2)..., 6)
    end
    move_agent!(AnimalAgent, pos, animalModel)
end

end
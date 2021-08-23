function update_agent!(AnimalAgent)
    AnimalAgent.age += 1 # Increment age by 1 day
    
    if AnimalAgent.treatment == :T 
        AnimalAgent.days_treated += 1
    elseif AnimalAgent.treatment == :PT
        AnimalAgent.since_tx += 1
    end

    # Change stage over time ------------------------
    if AnimalAgent.age < 60
        AnimalAgent.stage = :C
    elseif AnimalAgent.age ≥ 60 && AnimalAgent.age ≤ 13*30
        AnimalAgent.stage = :W
    elseif AnimalAgent.age > 13*30 && AnimalAgent.age ≤ 24*30
        AnimalAgent.stage = :H
    elseif AnimalAgent.age > 24*30 && AnimalAgent.stage != :D
        AnimalAgent.stage = :L 
    elseif AnimalAgent.stage == :D && AnimalAgent.days_dry > rand(60:90)
        AnimalAgent.dim = 0
        AnimalAgent.days_dry = 0
    end

    #Increase dim --------------------

    if AnimalAgent.stage == :L 
        AnimalAgent.dim += 1
    else
        AnimalAgent.dim = AnimalAgent.dim
    end

    # Dryoff -------------------

    if AnimalAgent.stage == :L && AnimalAgent.dim > (rand(305:400))
        AnimalAgent.stage = :D
        AnimalAgent.days_dry += 1
    else
        AnimalAgent.stage = AnimalAgent.stage
    end

    if AnimalAgent.stage == :D
        AnimalAgent.days_dry += 1
    else
        return
    end

    # Calve ----------------------

    if AnimalAgent.stage == :D && AnimalAgent.days_dry > (rand(60:90))
        AnimalAgent.stage = :L
        AnimalAgent.dim = 0
    else
        return
    end



end

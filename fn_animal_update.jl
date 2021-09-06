function update_agent!(AnimalAgent, animalModel)
    AnimalAgent.age += 1 # Increment age by 1 day
    
    if AnimalAgent.treatment == :T 
        AnimalAgent.days_treated += 1
    elseif AnimalAgent.treatment == :PT
        AnimalAgent.since_tx += 1
    end

    # Change stage over time ------------------------
    # Calves 
    if AnimalAgent.age < 60 && AnimalAgent.stage != :W
        AnimalAgent.stage = :C
    # Wean 
    elseif AnimalAgent.stage == :C &&  (AnimalAgent.age == rand(truncated(Poisson(60), 55, 70)))
        AnimalAgent.stage = :W
    elseif AnimalAgent.stage == :W && (AnimalAgent.age == rand(truncated(Poisson(13*30), 13*30, (13*30 + 9*7))))
        AnimalAgent.stage = :H
    elseif AnimalAgent.stage == :H && (AnimalAgent.age == rand(truncated(Poisson(24*30),(24*30), (24*30 + 63))))
        AnimalAgent.stage = :L
        AnimalAgent.dim = 0
        fn_animal_birth!(animalModel)
    elseif AnimalAgent.stage == :D && (AnimalAgent.days_dry > rand(truncated(Poisson(75), 60, 90)))
        AnimalAgent.stage = :L
        AnimalAgent.dim = 0
        fn_animal_birth!(animalModel)
    elseif AnimalAgent.stage == :L && (AnimalAgent.dim > rand(truncated(Poisson(320), 300, 400)))
        AnimalAgent.stage = :D
        AnimalAgent.days_dry = 0
    end

    #Increment days in milk (dim) --------------------

    if AnimalAgent.stage == :L 
        AnimalAgent.dim += 1
    else
        AnimalAgent.dim = AnimalAgent.dim
    end

    # Increment days dry ---------------------
    if AnimalAgent.stage == :D
        AnimalAgent.days_dry += 1
    else
        return
    end


end

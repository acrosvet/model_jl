function update_agent!(AnimalAgent, animalModel)

   # println(rand(animalModel.rng))

    AnimalAgent.age += 1 # Increment age by 1 day
    
    if AnimalAgent.treatment == :T 
        AnimalAgent.days_treated += 1
    elseif AnimalAgent.treatment == :PT
        AnimalAgent.since_tx += 1
    end

    # Make cows pregnant

    if (AnimalAgent.stage == :L && AnimalAgent.pregstat == :E) && (AnimalAgent.dim == rand(truncated(Poisson(142),110, 194)))
            AnimalAgent.pregstat = :P
    end



    # Change stage over time ------------------------
    # Calves 
    if AnimalAgent.age < 60 && AnimalAgent.stage != :W
        AnimalAgent.stage = :C
    end

    # Wean 
    if AnimalAgent.stage == :C && (AnimalAgent.age ≥ rand(truncated(Poisson(60), 55, 70)))
        AnimalAgent.stage = :W
        id = AnimalAgent.id
        day = animalModel.calday
        age = AnimalAgent.age
        #println("Weaning $id  at age $age on day $day !")
    end

    # Weaned to heifer
    if AnimalAgent.stage == :W && (AnimalAgent.age ≥ rand(truncated(Poisson(13*30), 13*30, (13*30 + 9*7))))
        AnimalAgent.stage = :H
        id = AnimalAgent.id
        day = animalModel.calday
        age = AnimalAgent.age
        #println("Joining $id at age $age on day $day !")
        
    end

    # Heifer pregnant
    if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
        lambda = 13*30 + 21
        lower = 13*30 + 21
        upper = 13*30 + 120
        if AnimalAgent.age ≥ rand(truncated(Poisson(lambda),lower, upper))
            if rand(animalModel.rng) > 0.5
                AnimalAgent.pregstat = :P
            end    
        end
    end

     # Calve heifer to lactating and create calf
    if AnimalAgent.stage == :H && (AnimalAgent.age ≥ rand(truncated(Poisson(24*30),(24*30), (24*30 + 63))))
        AnimalAgent.stage = :L
        AnimalAgent.pregstat = :E
        AnimalAgent.dim = 0
        id = AnimalAgent.id
        day = animalModel.calday
        age = AnimalAgent.age
        println("Calving $id at age $age on day $day")
        # Only 50% of the calves born will be retained
        if rand(animalModel.rng) > 0.5
            birth!(animalModel)
            # adds minimal agents
        end
    end 
    

    # Calve dry cow and create calf
    if AnimalAgent.stage == :D && (AnimalAgent.days_dry > rand(truncated(Poisson(75), 60, 90)))
        AnimalAgent.stage = :L
        AnimalAgent.pregstat = :E
        AnimalAgent.dim = 0
        id = AnimalAgent.id
        day = animalModel.calday
        age = AnimalAgent.age
        #println("Calving $id at age $age on day $day")
        # Only 50% of the calves born will be retained
        if rand(animalModel.rng) > 0.5
           birth!(animalModel)
           # This adds many agents
        end
    end


    # Dry off lactating cow 
    if AnimalAgent.stage == :L && (AnimalAgent.dim > rand(truncated(Poisson(320), 300, 400)))
        AnimalAgent.stage = :D
        AnimalAgent.days_dry = 0
    end

    #Increment days in milk (dim) --------------------

    if AnimalAgent.stage == :L 
        AnimalAgent.dim += 1
    end

    # Increment days dry ---------------------
    if AnimalAgent.stage == :D
        AnimalAgent.days_dry += 1
    end


end

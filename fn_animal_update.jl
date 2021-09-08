function update_agent!(AnimalAgent, animalModel)

   # println(rand(animalModel.rng))

    AnimalAgent.age += 1 # Increment age by 1 day
    
    if AnimalAgent.treatment == :T 
        AnimalAgent.days_treated += 1
    elseif AnimalAgent.treatment == :PT
        AnimalAgent.since_tx += 1
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

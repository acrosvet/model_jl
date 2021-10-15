function update_agent!(AnimalAgent)

   # println(rand(animalModel.rng))

    AnimalAgent.age += 1 # Increment age by 1 day
    
    if AnimalAgent.treatment == :T 
        AnimalAgent.days_treated += 1
    elseif AnimalAgent.treatment == :PT
        AnimalAgent.since_tx += 1
    end

    if AnimalAgent.treatment == :T
        AnimalAgent.days_treated += 1
    end
    
# Increment days infected, exposed and recovered
    if (AnimalAgent.status == :IR || AnimalAgent.status == :IS) && AnimalAgent.inf_days == 0
        AnimalAgent.inf_days = 1
        AnimalAgent.days_exposed = 0
    end
    
    if AnimalAgent.inf_days != 0
        AnimalAgent.inf_days +=1 
    elseif AnimalAgent.days_recovered != 0
        AnimalAgent.days_recovered += 1
    elseif  AnimalAgent.days_exposed != 0
        AnimalAgent.days_exposed += 1
    elseif AnimalAgent.days_carrier != 0
        AnimalAgent.days_carrier += 1
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

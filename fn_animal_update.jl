function update_agent!(AnimalAgent)


    AnimalAgent.age += 1 # Increment age by 1 day
    
    advance_pregnancy!(AnimalAgent)


# If animal is treated. advance treatment by one day
    if AnimalAgent.treatment == :T 
        AnimalAgent.days_treated += 1
    elseif AnimalAgent.treatment == :PT
        AnimalAgent.since_tx += 1
    end
 
# If animal is infected, advance infection status by one day
    if AnimalAgent.inf_days != 0
        AnimalAgent.inf_days +=1 
    end

# If the bacterial populaiton of the animal is above 0.5 and it is not recovered, it becomes infectious.
    if AnimalAgent.bactopop_is >= 0.5 && AnimalAgent.status != :recovered
        AnimalAgent.status = :IS
        AnimalAgent.inf_days = 1
        AnimalAgent.days_exposed = 0
    elseif AnimalAgent.bactopop_r >= 0.5 && AnimalAgent.status != :recovered
        AnimalAgent.status = :IR
        AnimalAgent.inf_days = 1
        AnimalAgent.days_exposed = 0
    end

# Increment days recovered if this is not 0

    if AnimalAgent.days_recovered != 0
        AnimalAgent.days_recovered += 1
    end

# Increment days exposed
    if  AnimalAgent.days_exposed != 0
        AnimalAgent.days_exposed += 1
    end

# Increment days carrier
    if AnimalAgent.days_carrier != 0
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

# Animals may clear infection. If they have not become infectious after 7 days, they are susceptible again.

    if AnimalAgent.status == :ES
        if AnimalAgent.bactopop_is < 0.5 && AnimalAgent.days_exposed >= 7
            AnimalAgent.status = :recovered
            AnimalAgent.days_exposed = 0
        end
    elseif AnimalAgent.status == :ER
        if AnimalAgent.bactopop_r < 0.5 && AnimalAgent.days_exposed >= 7
            AnimalAgent.status = :recovered
            AnimalAgent.days_exposed = 0
        end
    end



end

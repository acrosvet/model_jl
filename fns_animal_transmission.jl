
# Fn - Transmit resistant (Animal) ------------------------
function transmit_resistant!(a1,a2,animalModel)
    count(a.status == :IR for a in (a1, a2)) ≠ 1 && return
        infected, healthy = a1.status == :IR ? (a1, a2) : (a2, a1)
#If a random number is below the transmssion parameter, infect, provided that the contacted animal is susceptible.
        if (rand(animalModel.rng) < infected.βᵣ*infected.bactopop) && healthy.status == :S
            healthy.status = :ER
            healthy.submodel = infected.submodel
            healthy.submodel.total_status = healthy.status
            healthy.days_exposed += 1*time_resolution
        else
            healthy.status = healthy.status
        end

end

# Fn - Transmit sensitive (Animal) -----------------------    
function transmit_sensitive!(a1,a2,animalModel)
    # Both calves cannot be infected, if they are, return from the function. It also can't be 0
    count(a.status == :IS for a in (a1, a2)) ≠ 1 && return
    # Else define a tuple of infected, healthy, depending on whether a1 or a2 is infected. infected will always be the first tuple position.
    infected, healthy = a1.status == :IS ? (a1, a2) : (a2, a1)

    #IF a random number is greater than βₛ, then we return out of the function
    
    if (rand(animalModel.rng) < infected.βₛ*(1-infected.bactopop)) && healthy.status == :S
        healthy.status = :ES
        healthy.submodel = infected.submodel
        healthy.submodel.total_status = healthy.status
        healthy.days_exposed += 1*time_resolution
                # Else we set the status of the healthy animal to IS
    else
        healthy.status = healthy.status
    end
    println("Days exposed is:")
    println(healthy.days_exposed)
end

function exposed_to_infectious!(AnimalAgent)
# If the number of days infected exceeds an infectious duration from a Poisson distribution with λ = 3, then the animal becomes infectious
    if AnimalAgent.status == :ES && (AnimalAgent.days_exposed ≥ rand(Poisson(3)))
        AnimalAgent.status = :IS
        AnimalAgent.submodel.total_status = AnimalAgent.status
        AnimalAgent.inf_days += 1*time_resolution
    elseif AnimalAgent.status == :ER
        AnimalAgent.status = :IR
        AnimalAgent.submodel.total_status = AnimalAgent.status
        AnimalAgent.inf_days += 1*time_resolution
    end
    println("Days infected is: ")
    println(AnimalAgent.inf_days)
end



# Fn - Transmit carrier (Animal) ----------------------------    
function transmit_carrier!(a1,a2,animalModel)
    # Both calves cannot be infected, if they are, return from the function. It also can't be 0
    count(a.status == :CS for a in (a1, a2)) ≠ 1 && return
    # Else define a tuple of infected, healthy, depending on whether a1 or a2 is infected. infected will always be the first tuple position.
    infected, healthy = a1.status == :CS ? (a1, a2) : (a2, a1)

    #IF a random number is greater than βₛ, then we return out of the function
    
    if (rand(animalModel.rng) < rand(animalModel.rng)*infected.βₛ) && (healthy.status == :S || healthy.status == :RS)
        if healthy.treatment == :PT && (rand(animalModel.rng) < rand(animalModel.rng)*infected.βᵣ)
            healthy.status = :IR
            healthy.inf_days_ir = 0
        else
            healthy.status = :IS
            healthy.inf_days_is = 0
        end
        # Else we set the status of the healthy animal to its existing status
    else
        healthy.status = healthy.status
    end
end

# Fn - Transmit carrier (Animal) ---------------------------------------    
function transmit_carrier_is!(a1,a2,animalModel)
    # Both calves cannot be infected, if they are, return from the function. It also can't be 0
    count(a.status == :CS for a in (a1, a2)) ≠ 1 && return
    # Else define a tuple of infected, healthy, depending on whether a1 or a2 is infected. infected will always be the first tuple position.
    infected, healthy = a1.status == :CS ? (a1, a2) : (a2, a1)

    #IF a random number is greater than βₛ, then we return out of the function
    
    if (rand(animalModel.rng) < rand(animalModel.rng)*infected.βₛ) && (healthy.status == :S || healthy.status == :RS)
        if healthy.treatment == :PT && (rand(animalModel.rng) < rand(animalModel.rng)*infected.βᵣ)
            healthy.status = :IR
            healthy.inf_days_ir = 0
        else
            healthy.status = :IS
            healthy.inf_days_is = 0
        end
        # Else we set the status of the healthy animal to its existing status
    else
        healthy.status = healthy.status
    end
end

function transmit_carrier_ir!(a1,a2,animalModel)
    # Both calves cannot be infected, if they are, return from the function. It also can't be 0
    count(a.status == :CR for a in (a1, a2)) ≠ 1 && return
    # Else define a tuple of infected, healthy, depending on whether a1 or a2 is infected. infected will always be the first tuple position.
    infected, healthy = a1.status == :CR ? (a1, a2) : (a2, a1)

    #IF a random number is greater than βₛ, then we return out of the function
    
    if (rand(animalModel.rng) < rand(animalModel.rng)*infected.βᵣ) && (healthy.status == :S || healthy.status == :RS || healthy.status == :RR)
            healthy.status = :ER
            healthy.inf_days_ir = 0
        # Else we set the status of the healthy animal to its existing status
    else
        healthy.status = healthy.status
    end
end


# Fn - retreatment ----------------------------------------------------------

function retreatment!(AnimalAgent, animalModel)
    # Assign a treatment status
    if (AnimalAgent.status == :IS || AnimalAgent.status == :IR)
        if AnimalAgent.treatment == :PT && (rand(animalModel.rng) < animalModel.treatment_prob)
            AnimalAgent.treatment == :RT 
        else
            AnimalAgent.treatment = AnimalAgent.treatment
        end
    end

end


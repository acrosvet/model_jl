
# Fn - Treatment effect (Animal) -------------------------    
function treatment_effect!(AnimalAgent)
    # During treatment, sensitive calves become less contagious
    if AnimalAgent.treatment == :T && AnimalAgent.status == :IS
        AnimalAgent.βₛ = 0.8(AnimalAgent.βₛ)
    # Resistant calves remain unchanged
    elseif AnimalAgent.treatment == :T && AnimalAgent.status == :IR
        AnimalAgent.βᵣ = AnimalAgent.βᵣ
    end

    end

    # Fn - End of treatment ---------------------------    

function endTreatment!(AnimalAgent, animalModel)
    #Define the endpoint of treatment
            if AnimalAgent.treatment != :T && return
            elseif AnimalAgent.days_treated ≥ animalModel.treatment_duration
                AnimalAgent.treatment = :PT
            end
    end

# Fn - start of treatment -------------------------    

function treatment!(AnimalAgent, animalModel)
        # Assign a treatment status
        if (AnimalAgent.status != :IS && AnimalAgent.status != :IR) && return
        elseif AnimalAgent.treatment == :U && (rand(animalModel.rng) < animalModel.treatment_prob)
            AnimalAgent.treatment = :T
            
        end
    
    end

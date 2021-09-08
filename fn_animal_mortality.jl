function mortality!(AnimalAgent, animalModel)
    # If an animal is infected sensitive, cull if it is eligible to be culled
#=     if AnimalAgent.status == :IS && (rand(animalModel.rng) < animalModel.mortalityRateSens)
        kill_agent!(AnimalAgent, animalModel)
    # The same for animals infected with resistant bacteria, according to that mortality rate
    elseif AnimalAgent.status == :IR && (rand(animalModel.rng) < animalModel.mortalityRateRes)
        kill_agent!(AnimalAgent, animalModel)
    end
 =#
    # Cull agent -------------------------------

    function current_stock(animalModel, stage)
        counter = 0
        for i in 1:length(animalModel.agents)
            if (haskey(animalModel.agents, i) == true) && animalModel.agents[i].stage == stage
                counter += 1
            end
        end
        return counter

    end

    current_lactating = current_stock(animalModel, :L)
    println(animalModel.num_lac)
    println(current_lactating)

    # Cull cows ------------------------------------
    if (AnimalAgent.age ≥ rand(truncated(Poisson(floor(8*365)), 2*365, 9*365))) 
        if current_lactating > animalModel.num_lac
            kill_agent!(AnimalAgent, animalModel)
            println("Cow culled!")
        end
    end

    if (AnimalAgent.stage == :L && AnimalAgent.pregstat == :E) && (AnimalAgent.dim ≥ 280)
        
        if current_lactating > animalModel.num_lac
            if rand(animalModel.rng) > 0.5
                kill_agent!(AnimalAgent, animalModel)
                println("Infertility cull!")
            end
        end
    end

    current_heifers = current_stock(animalModel, :H)

    # cull heifers
    if AnimalAgent.stage == :H 
        if AnimalAgent.age == 516 && current_heifers > animalModel.num_heifers
                if AnimalAgent.pregstat == :E
                    kill_agent!(AnimalAgent, animalModel)
                    println("Heifer cull")
                end
        elseif current_heifers > animalModel.num_heifers && AnimalAge > 516
            kill_agent!(AnimalAgent, animalModel)
            println("Heifer cull")
        end
    
    end
end

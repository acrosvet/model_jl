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

    # Cull cows ------------------------------------
    if (AnimalAgent.age ≥ rand(truncated(Poisson(floor(7.5*365)), 2*365, 8*365)))
        kill_agent!(AnimalAgent, animalModel)
        println("Cow culled!")
    end

    if (AnimalAgent.stage == :L && AnimalAgent.pregstat == :E) && (AnimalAgent.dim ≥ 160)
        kill_agent!(AnimalAgent, animalModel)
        println("Infertility cull!")
    end

    # cull heifers
    if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
        if AnimalAgent.age ≥ (13*30 + 84)
            kill_agent!(AnimalAgent, animalModel)
            println("Heifer cull")
        end
    end
end

function mortality!(AnimalAgent, animalModel)
    # If an animal is infected sensitive, cull if it is eligible to be culled
    if AnimalAgent.status == :IS && (rand() < animalModel.mortalityRateSens)
        kill_agent!(AnimalAgent, animalModel)
    # The same for animals infected with resistant bacteria, according to that mortality rate
    elseif AnimalAgent.status == :IR && (rand() < animalModel.mortalityRateRes)
        kill_agent!(AnimalAgent, animalModel)
    end

    # Cull agent -------------------------------

    # Cull cows that have been in the herd for too long at a 30% replacement rate
    if (AnimalAgent.stage == :L && AnimalAgent.age ≥ 365*4) && (animalModel.culling_rate/365 > rand())
        kill_agent!(AnimalAgent, animalModel)
    end

end

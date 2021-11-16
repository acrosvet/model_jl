function mortality!(AnimalAgent, animalModel)

# If the animal is infected and resistant it has a probability of death regardless of treatment, with mature animals less likely to die than calves.
    if AnimalAgent.status == :IR 
        if AnimalAgent.stage == :C
            if rand(animalModel.rng) < rand(animalModel.rng, 0.05:0.01:0.3)
                if haskey(animalModel.agents, AnimalAgent.id)
                    kill_agent!(AnimalAgent, animalModel)
                end
            else
                if rand(animalModel.rng) < rand(animalModel.rng, 0.001:0.001:0.01)
                    if haskey(animalModel.agents, AnimalAgent.id)
                        kill_agent!(AnimalAgent, animalModel)
                    end
                end
            end
        end
# If the animal is mature, it is only likely to die if it remains untreated.
    elseif AnimalAgent.status == :IS && AnimalAgent.treatment == :U 
        if AnimalAgent.stage == :C
            if rand(animalModel.rng) < rand(animalModel.rng, 0.05:0.01:0.3)
                if haskey(animalModel.agents, AnimalAgent.id)
                    kill_agent!(AnimalAgent, animalModel)
                end
            else
                if rand(animalModel.rng) < rand(animalModel.rng, 0.001:0.001:0.01)
                    if haskey(animalModel.agents, AnimalAgent.id)
                        kill_agent!(AnimalAgent, animalModel)
                    end
                end
            end
        end

    end

end
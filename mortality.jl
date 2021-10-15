function mortality!(AnimalAgent, animalModel)

    if AnimalAgent.status == :IR 
        if AnimalAgent.stage == :C
            if rand(animalModel.rng) < 0.3
                if haskey(animalModel.agents, AnimalAgent.id)
                    kill_agent!(AnimalAgent, animalModel)
                end
            else
                if rand(animalModel.rng) < 0.01
                    if haskey(animalModel.agents, AnimalAgent.id)
                        kill_agent!(AnimalAgent, animalModel)
                    end
                end
            end
        end

    end

end
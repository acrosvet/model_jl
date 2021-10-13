function thread_submodel!(AnimalAgent, animalModel)
        AnimalAgent.submodel.rng = MersenneTwister(hash(AnimalAgent))
        Random.seed!(AnimalAgent.submodel.rng)
        Threads.@spawn step!(AnimalAgent.submodel, bact_agent_step!, bact_model_step!,1)

 end    
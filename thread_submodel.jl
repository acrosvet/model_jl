function thread_submodel!(AnimalAgent, animalModel)
        AnimalAgent.submodel.rng = MersenneTwister(hash(AnimalAgent))
        Random.seed!(AnimalAgent.submodel.rng)
        #step!(a.submodel, bact_agent_step!, bact_model_step!,1)
         #AnimalAgent.submodel.seed = AnimalAgent.id + animalModel.seed
        @async Threads.@spawn step!(AnimalAgent.submodel, bact_agent_step!, bact_model_step!,1)

 end
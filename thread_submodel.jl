function thread_submodel!(AnimalAgent, animalModel)


         AnimalAgent.submodel.seed = AnimalAgent.id + animalModel.seed
         Threads.@spawn step!(AnimalAgent.submodel, bact_agent_step!, bact_model_step!,1)

 end
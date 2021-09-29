function thread_submodel!(animalModel)

     #Threads.@threads 
     for a in collect(allagents(animalModel))
         a.submodel.seed = a.id + animalModel.seed
         Threads.@spawn step!(a.submodel, bact_agent_step!, bact_model_step!,1)
     end
 
 end
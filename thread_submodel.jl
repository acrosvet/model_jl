function thread_submodel!(animalModel)



   Threads.@spawn  for a in allagents(animalModel)
        a.submodel.seed = animalModel.id
        step!(a.submodel, bact_agent_step!, bact_model_step!,1)
    end

end
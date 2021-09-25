function thread_submodel!(animalModel)

    for i in 1:length(allagents)
        animalModel.submodel.seed = animalModel.submodel.seed + i
    end

   Threads.@spawn  for a in allagents(animalModel)
        step!(a.submodel, bact_agent_step!, bact_model_step!,1)
    end

end
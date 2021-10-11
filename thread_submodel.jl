function thread_submodel!(AnimalAgent, animalModel)
        AnimalAgent.submodel.rng = MersenneTwister(hash(AnimalAgent))
        Random.seed!(AnimalAgent.submodel.rng)
        #step!(a.submodel, bact_agent_step!, bact_model_step!,1)
         #AnimalAgent.submodel.seed = AnimalAgent.id + animalModel.seed
        # data, _ = run!(farmModel, farm_step!)
        out = @async Threads.@spawn data, _ = run!(AnimalAgent.submodel, bact_agent_step!, bact_model_step!,1; adata)
        fetch(out)
        CSV.write("./integrated_export_1825.csv", data, append = true)
 end    
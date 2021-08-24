    function run_submodel!(AnimalAgent, animalModel)
    # Add in bacterial data output


    id = AnimalAgent.id

    animalModel.submodel.properties[:total_status] = AnimalAgent.status
    animalModel.submodel.properties[:days_treated] = AnimalAgent.days_treated
    animalModel.submodel.age = AnimalAgent.age
    
    if haskey(animalModel.agents, id)
    

        resistant(x) = count(i == :R for i in x)
        sensitive(x) = count(i == :IS for i in x)
        susceptible(x) = count(i == :S for i in x)
        adata = [
        (:status, resistant),
        (:status, sensitive),
        (:status, susceptible)
        ]
    

        bactostep, _ = run!(animalModel[id].submodel, bact_agent_step!, 1; adata)

        sense = bactostep[:,:sensitive_status][2]
        res = bactostep[:,:resistant_status][2]
        sus = bactostep[:,:susceptible_status][2]
        prop_res = res/(sense + res)

        animalModel[id].bactopop = prop_res
    else
        return
    end
    end
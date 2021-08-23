    function run_submodel!(AnimalAgent, animalModel)
    # Add in bacterial data output
    resistant(x) = count(i == :R for i in x)
    sensitive(x) = count(i == :IS for i in x)
    susceptible(x) = count(i == :S for i in x)
    adata = [
    (:status, resistant),
    (:status, sensitive),
    (:status, susceptible)
    ]

    id = AnimalAgent.id

    animalModel.submodel.properties[:total_status] = AnimalAgent.status
    animalModel.submodel.properties[:days_treated] = AnimalAgent.days_treated
    animalModel.submodel.age = AnimalAgent.age

    bactostep, _ = run!(animalModel.submodel[id], bact_agent_step!; adata)

    sense = bactostep[:,:sensitive_status][2]
    res = bactostep[:,:resistant_status][2]
    sus = bactostep[:,:susceptible_status][2]
    prop_res = res/animalModel.submodel.nbact

    animalModel.bactopop = prop_res
    end
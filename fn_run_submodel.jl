    function run_submodel!(AnimalAgent, animalModel)

    # Update the submodel parameters

    AnimalAgent.submodel.animalno = AnimalAgent.id
    AnimalAgent.submodel.days_treated = AnimalAgent.days_treated
    AnimalAgent.submodel.age = AnimalAgent.age
    AnimalAgent.submodel.days_exposed = AnimalAgent.days_exposed
    AnimalAgent.submodel.days_recovered = AnimalAgent.days_recovered
    AnimalAgent.submodel.days_treated = AnimalAgent.days_treated
    
    # run the submodel
    step!(AnimalAgent.submodel, bact_agent_step!, bact_model_step!,1)

    end
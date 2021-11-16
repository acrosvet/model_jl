    function run_submodel!(AnimalAgent, animalModel)

    # Update the submodel parameters to reflect the animal parameters
    AnimalAgent.submodel.step = animalModel.step
    AnimalAgent.submodel.total_status = AnimalAgent.status
    AnimalAgent.submodel.animalno = AnimalAgent.id
    AnimalAgent.submodel.days_treated = AnimalAgent.days_treated
    AnimalAgent.submodel.age = AnimalAgent.age
    AnimalAgent.submodel.days_exposed = AnimalAgent.days_exposed
    AnimalAgent.submodel.days_recovered = AnimalAgent.days_recovered
    AnimalAgent.submodel.days_treated = AnimalAgent.days_treated


# Advance the bacterial submodel one time step.
    if AnimalAgent.status != :S || ((AnimalAgent.status == :recovered || AnimalAgent.status == :RR || AnimalAgent.status == :RS) && (AnimalAgent.bactopop_is > 0.1 || AnimalAgent.bactopop_r > 0.1))

            step!(AnimalAgent.submodel, bact_agent_step!, bact_model_step!)
            println("Stepped")

    end

    end
    function run_submodel!(AnimalAgent, animalModel)

        if AnimalAgent.bactopop_is > 0.5 && AnimalAgent.status != :recovered
            AnimalAgent.status = :IS
        elseif AnimalAgent.bactopop_r > 0.5 && AnimalAgent.status != :recovered
            AnimalAgent.status = :IR
        end
     
    


    # Update the submodel parameters
    AnimalAgent.submodel.step = animalModel.step
    AnimalAgent.submodel.total_status = AnimalAgent.status
    AnimalAgent.submodel.animalno = AnimalAgent.id
    AnimalAgent.submodel.days_treated = AnimalAgent.days_treated
    AnimalAgent.submodel.age = AnimalAgent.age
    AnimalAgent.submodel.days_exposed = AnimalAgent.days_exposed
    AnimalAgent.submodel.days_recovered = AnimalAgent.days_recovered
    AnimalAgent.submodel.days_treated = AnimalAgent.days_treated

    if AnimalAgent.status != :S
        if AnimalAgent.status == :recovered && (AnimalAgent.bactopop_is < 0.1 || AnimalAgent.bactopop_r < 0.1)
            return
        else
            step!(AnimalAgent.submodel, bact_agent_step!, bact_model_step!)
            println("Stepped")
        end
    end

    end
    function run_submodel!(AnimalAgent, animalModel)

        if AnimalAgent.bactopop_is > 0.5 
            AnimalAgent.status = :IS
        elseif AnimalAgent.bactopop_r > 0.5
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
#=     AnimalAgent.bactopop_is = AnimalAgent.submodel.sensitive_pop
    AnimalAgent.bactopop_r = AnimalAgent.submodel.resistant_pop =#
    



    bact_model_step!(AnimalAgent.submodel)

    for a in collect(allagents(AnimalAgent.submodel))
         bact_agent_step!(a, AnimalAgent.submodel)
    end

    # run the submodel
    #step!(AnimalAgent.submodel, bact_agent_tep!, bact_model_step!,1)

    end
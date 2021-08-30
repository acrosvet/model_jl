
    function agent_step!(AnimalAgent, animalModel, FarmAgent)
        #move_agent!(AnimalAgent, animalModel, animalModel.timestep) #Move the agent in space
        treatment!(AnimalAgent, animalModel) #Introduce treatment
        treatment_effect!(AnimalAgent) #Effect of treatment on transmission.
        endTreatment!(AnimalAgent, animalModel)
        retreatment!(AnimalAgent, animalModel) #Effect of retreatment
        mortality!(AnimalAgent, animalModel) #Introduce mortality
        recover!(AnimalAgent, animalModel) # Introduce recovery
        carrierState!(AnimalAgent, animalModel) #Introduce a carrier state
        update_agent!(AnimalAgent) #Apply the update_agent function
        run_submodel!(AnimalAgent, animalModel)
        bacto_dyno!(AnimalAgent)
        daytrader!(FarmAgent, animalModel)

    end


    function agent_step!(AnimalAgent, animalModel)
        move_agent!(AnimalAgent, animalModel, animalModel.timestep) #Move the agent in space
        exposed_to_infectious!(AnimalAgent) # Transition exposed animals to infectiousness
        treatment!(AnimalAgent, animalModel) #Introduce treatment
        treatment_effect!(AnimalAgent) #Effect of treatment on transmission.
        endTreatment!(AnimalAgent, animalModel) #End treatment
        retreatment!(AnimalAgent, animalModel) #Effect of retreatment
        mortality!(AnimalAgent, animalModel) #Introduce mortality
        recover!(AnimalAgent, animalModel) # Introduce recovery
        carrierState!(AnimalAgent, animalModel) #Introduce a carrier state
        update_agent!(AnimalAgent) #Apply the update_agent function
        run_submodel!(AnimalAgent, animalModel) #Run the bacterial submodel
        bacto_dyno!(AnimalAgent) #Determine the overall bacterial dynamics for an animal
        flag_trades!(AnimalAgent, animalModel)

    end
 
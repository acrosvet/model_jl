"""

agent_step!(AnimalAgent, animalModel)

Step AnimalAgents through time

"""
    function agent_step!(AnimalAgent, animalModel)
        #= move_agent!(AnimalAgent, animalModel, animalModel.timestep) #Move the agent in space
        exposed_to_infectious!(AnimalAgent) # Transition exposed animals to infectiousness
        treatment!(AnimalAgent, animalModel) #Introduce treatment
        treatment_effect!(AnimalAgent) #Effect of treatment on transmission.
        endTreatment!(AnimalAgent, animalModel) #End treatment
        retreatment!(AnimalAgent, animalModel) #Effect of retreatment
        recover!(AnimalAgent, animalModel) # Introduce recovery
        carrierState!(AnimalAgent, animalModel) #Introduce a carrier state
        run_submodel!(AnimalAgent, animalModel) #Run the bacterial submodel
        bacto_dyno!(AnimalAgent) #Determine the overall bacterial dynamics for an animal =#
        #mortality!(AnimalAgent, animalModel) #Introduce mortality
        cull_milkers!(AnimalAgent, animalModel)
        advance_pregnancy!(AnimalAgent)
        heat!(AnimalAgent)
        calving!(AnimalAgent, animalModel)
        bobby_cull!(AnimalAgent, animalModel)
        joining!(AnimalAgent, animalModel)
        wean!(AnimalAgent, animalModel)
        heifer!(AnimalAgent, animalModel)
        heifer_joining!(AnimalAgent, animalModel)
        
        dryoff!(AnimalAgent, animalModel)
        update_agent!(AnimalAgent) #Apply the update_agent function
        #flag_trades!(AnimalAgent, animalModel)
        export_animal_data!(AnimalAgent, animalModel)


    end
 
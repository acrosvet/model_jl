"""

agent_step!(AnimalAgent, animalModel)

Step AnimalAgents through time

"""
    function agent_step!(AnimalAgent, animalModel)
        #= 
        treatment!(AnimalAgent, animalModel) #Introduce treatment
        treatment_effect!(AnimalAgent) #Effect of treatment on transmission.
        endTreatment!(AnimalAgent, animalModel) #End treatment
        retreatment!(AnimalAgent, animalModel) #Effect of retreatment
        run_submodel!(AnimalAgent, animalModel) #Run the bacterial submodel
        bacto_dyno!(AnimalAgent) #Determine the overall bacterial dynamics for an animal =#
        agent_movement!(AnimalAgent, animalModel)
        cull_milkers!(AnimalAgent, animalModel)
        advance_pregnancy!(AnimalAgent)
        #heat!(AnimalAgent)
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
        export_animal_position!(AnimalAgent, animalModel)
        latency!(AnimalAgent, animalModel)
        recovery!(AnimalAgent, animalModel)
        transmit!(AnimalAgent, animalModel)



    end
 
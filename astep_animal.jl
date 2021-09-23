"""

agent_step!(AnimalAgent, animalModel)

Step AnimalAgents through time

"""
    function agent_step!(AnimalAgent, animalModel)
        bacto_dyno!(AnimalAgent)
        run_submodel!(AnimalAgent, animalModel)
        agent_movement!(AnimalAgent, animalModel)
        cull_milkers!(AnimalAgent, animalModel)
        advance_pregnancy!(AnimalAgent)
        calving!(AnimalAgent, animalModel)
        bobby_cull!(AnimalAgent, animalModel)
        joining!(AnimalAgent, animalModel)
        wean!(AnimalAgent, animalModel)
        heifer!(AnimalAgent, animalModel)
        heifer_joining!(AnimalAgent, animalModel)
        dryoff!(AnimalAgent, animalModel)
        update_agent!(AnimalAgent) #Apply the update_agent function
        export_animal_data!(AnimalAgent, animalModel)
        export_animal_position!(AnimalAgent, animalModel)
        #latency!(AnimalAgent, animalModel)
        transmit!(AnimalAgent, animalModel)
        recovery!(AnimalAgent, animalModel)



    end
 
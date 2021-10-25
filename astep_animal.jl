"""

agent_step!(AnimalAgent, animalModel)

Step AnimalAgents through time

"""
    function agent_step!(AnimalAgent, animalModel)

        

        transmit!(AnimalAgent, animalModel)
        recovery!(AnimalAgent, animalModel)
        treatment!(AnimalAgent, animalModel)
        endTreatment!(AnimalAgent, animalModel)

#Run submodel
run_submodel!(AnimalAgent, animalModel)

#Transmission functions
update_agent!(AnimalAgent) #Apply the update_agent function


        if animalModel.step > 1
            agent_movement!(AnimalAgent, animalModel)
        end



        #Population dynamics
        cull_milkers!(AnimalAgent, animalModel)
        advance_pregnancy!(AnimalAgent)
        calving!(AnimalAgent, animalModel)
        bobby_cull!(AnimalAgent, animalModel)
        joining!(AnimalAgent, animalModel)
        wean!(AnimalAgent, animalModel)
        heifer!(AnimalAgent, animalModel)
        heifer_joining!(AnimalAgent, animalModel)
        dryoff!(AnimalAgent, animalModel)
        
        # Trading flags
        flag_trades!(AnimalAgent,animalModel)

        #Export functions
        #export_animal_data!(AnimalAgent, animalModel)
       
       # export_animal_position!(AnimalAgent, animalModel)


    end
 
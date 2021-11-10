"""

agent_step!(AnimalAgent, animalModel)

Step AnimalAgents through time

"""
    function agent_step!(AnimalAgent, animalModel)

        update_agent!(AnimalAgent)#Step the agent through time, updating state parameters   

        mortality!(AnimalAgent, animalModel)#Probability of infected animals dying
        recovery!(AnimalAgent, animalModel)#Define the dynamics of animals recovering from treatment.
        transmit!(AnimalAgent, animalModel)#Transmit infection directly between agents
        recrudescence!(AnimalAgent, animalModel)#Recrudecent infection from carriers
        treatment!(AnimalAgent, animalModel)#Apply treatment
        endTreatment!(AnimalAgent, animalModel)#End treatment
        run_submodel!(AnimalAgent, animalModel)


# Move the agents, but only after the first time step

        if animalModel.step > 1
            agent_movement!(AnimalAgent, animalModel)
        end
#Set the infected status of the initially infected agents
        if animalModel.step == 1
            if AnimalAgent.status == :IR || AnimalAgent.status == :IS
                AnimalAgent.inf_days = 1
            end
        end



        #Population dynamics
        cull_milkers!(AnimalAgent, animalModel)#Cull lactating cows as required
        calving!(AnimalAgent, animalModel)#Create new calf agents as cows calve
        bobby_cull!(AnimalAgent, animalModel)#Cull bobby calves
        joining!(AnimalAgent, animalModel)#Join animals
        wean!(AnimalAgent, animalModel)#Transition - calf to weaned
        heifer!(AnimalAgent, animalModel)#Transition - weaned to heifer
        heifer_joining!(AnimalAgent, animalModel)# Join heifers
        dryoff!(AnimalAgent, animalModel)#Dry cows off
        
        # Trading flags
        flag_trades!(AnimalAgent,animalModel)#Determine what animals can be traded at any time step

        #Export functions
        export_animal_data!(AnimalAgent, animalModel)
       
       # export_animal_position!(AnimalAgent, animalModel)


# Run the animal's bacterial submodel


    end
 
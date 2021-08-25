function farm_update_agent!(FarmAgent, farmModel)
    id =  FarmAgent.id

    animalModel = farmModel[id].animalModel

    function animal_agent_step!(AnimalAgent, animalModel)
        move_agent!(AnimalAgent, animalModel, animalModel.timestep) #Move the agent in space
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
       

    end

    function model_step!(animalModel)
        
        #Define the proximity for which infection may occur
        birth!(animalModel)
        r = animalModel.animalProximityRadius
        for (a1,a2) in interacting_pairs(animalModel, r, :nearest)
            elastic_collision!(a1, a2) #Collison dynamics for each animal
            transmit_sensitive!(a1,a2, animalModel) #Sensitive transmission function
            transmit_resistant!(a1,a2,animalModel) #Resistant transmission function
            transmit_carrier_is!(a1,a2,animalModel)
            transmit_carrier_ir!(a1,a2,animalModel)
            
        end
        
        if animalModel.calday > 365
            animalModel.calday = 0
        else
            animalModel.calday = animalModel.calday
        end
    
        animalModel.calday += 1
    
        
        
    end
    

    

        susceptible(x) = count(i == :S for i in x)
    
        adata = [
        (:status, susceptible) 
        ]


    
    
        animals, _ = run!(farmModel[id].animalModel, animal_agent_step!, model_step!, 1; adata)
        
        has_stage(AnimalAgent, status) = AnimalAgent.status == status
    
        is_traded(status) = AnimalAgent -> has_stage(AnimalAgent, status) 
        
        traded_agent = random_agent(animalModel, is_traded(:IR))
        
        if typeof(traded_agent) == Nothing && return
        else
            trader_id = traded_agent.id
            push!(farmModel[id].animalModel.sending, traded_agent)
            println(farmModel[id].animalModel.sending)
        end

    
    end
    
function farm_update_agent!(FarmAgent, farmModel)
    id =  FarmAgent.id

    animalModel = farmModel[id].animalModel


    function agent_step!(AnimalAgent, animalModel)
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
        move_agent!(AnimalAgent, animalModel, animalModel.timestep) #Move the agent in space


       

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
        
        # Determine what animals can be traded
        has_stage(AnimalAgent, status) = AnimalAgent.status == status
        
        is_traded(status) = AnimalAgent -> has_stage(AnimalAgent, status) 
        
        # Select a number to be traded
        num_traded = rand(1:24)
        
        # Clear the to trade list from last step
        animalModel.sending = []
    
    
        # Put agents in the sending container according to number
        for animal in 1:num_traded
                
            traded_agent = random_agent(animalModel, is_traded(:S))
    
            push!(animalModel.sending, traded_agent)
    
           if haskey(animalModel.agents, traded_agent) == true
    
                kill_agent!(traded_agent, animalModel)
           end 
        end        


    # Add agents from the receiving container if this is not null
    if length(animalModel.receiving) != 0
        for i in 1:length(animalModel.receiving)
            agent = animalModel.receiving[i]
            newid = rand(1500:5000)
#=             while true
                haskey(animalModel.agents, newid)
                newid = rand(1500:5000)
                break
            end =#
            agent.id = newid 
            println(newid)
            #add_agent!(agent, animalModel)
        end

end

end

        run!(farmModel[id].animalModel, agent_step!, model_step!,1)
        
#=         trade_partners = node_neighbors(FarmAgent, farmModel)
        trade_partner = rand(1:length(trade_partners))
        if trade_partner == id 
            #println("EXIT!") 
        elseif length(farmModel[id].animalModel.sending) != 0 && trade_partner != id
            farmModel[trade_partner].animalModel.receiving = farmModel[id].animalModel.sending
           # println("traded") 
        end =#
end

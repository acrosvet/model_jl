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
    
        
        
    end
    

    

    
    
        run!(farmModel[id].animalModel, agent_step!, model_step!,1)
        
        has_stage(AnimalAgent, status) = AnimalAgent.status == status
        
        is_traded(status) = AnimalAgent -> has_stage(AnimalAgent, status) 
        
        traded_agent = random_agent(farmModel[id].animalModel, is_traded(:S))

       # println(traded_agent)
        println(typeof(traded_agent))



        
        if typeof(traded_agent) == AnimalAgent
            push!(farmModel[id].animalModel.sending, traded_agent)
            println("Pushed agent")
            trade_partners = node_neighbors(FarmAgent, farmModel)
            trade_partner = rand(1:length(trade_partners))
            if trade_partner == id 
                println("EXIT!") 
                return
            elseif length(farmModel[id].animalModel.sending) != 0 && trade_partner != id
                farmModel[trade_partner].animalModel.receiving = farmModel[id].animalModel.sending
                println("traded") 
                agent  = farmModel[trade_partner].animalModel.receiving[1]
                println("Number of agents before")
                println(length(farmModel[trade_partner].animalModel.agents))
                agent.id = rand(5000:1000000) # ran number for new agent id 4
                #push!(agent, farmModel[trade_partner].amimalModel.agents)
                #add_agent!(agent, farmModel[trade_partner].animalModel)
                #=
                #kill_agent!(agent, farmModel[id].animalModel)
                println("Agent sent", agent.id)
                println("Number of agents after")
                println(trade_partner)
                println(length(farmModel[trade_partner].animalModel.agents)) =#
            else
                return
            end
         else
            println("Didn't push agent")
        end 
  
    # Trade infection between farms 


 #   println(trade_partners)

#=     if typeof(trade_partners) == Nothing 
        return
    else
         trade_partner = rand(1:length(trade_partners))
        farmModel[trade_partner].animalModel.receiving = farmModel[id].animalModel.sending
        println(farmModel[trade_partner].animalModel.receiving) 
    end    
 =#
    
    end

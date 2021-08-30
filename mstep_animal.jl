function model_step!(animalModel)
    #Define the proximity for which infection may occur
    #birth!(animalModel)
    r = animalModel.animalProximityRadius
    for (a1,a2) in interacting_pairs(animalModel, r, :nearest)
        elastic_collision!(a1, a2) #Collison dynamics for each animal
        transmit_sensitive!(a1,a2, animalModel) #Sensitive transmission function
        transmit_resistant!(a1,a2, animalModel) #Resistant transmission function
        transmit_carrier_is!(a1,a2, animalModel)
        transmit_carrier_ir!(a1,a2, animalModel)
        
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

    if length(animalModel.receiving) != 0
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = Tuple(10*rand(animalModel.rng, 2))
        status = animalModel[1].status
        age = animalModel[1].age
        βᵣ = animalModel[1].βₛ
        βₛ = animalModel[1].βᵣ
        inf_days_ir = animalModel[1].inf_days_ir
        inf_days_is = animalModel[1].inf_days_is
        treatment = animalModel[1].treatment
        days_treated = animalModel[1].days_treated
        bactopop = animalModel[1].bactopop
        submodel = animalModel[1].submodel
        vel = animalModel[1].vel
        stage = animalModel[1].stage
        since_tx = animalModel[1].since_tx
        dim = animalModel[1].dim
        days_dry = animalModel[1].days_dry
        add_agent!(pos, animalModel, vel, age, status, βₛ, βᵣ, inf_days_is, inf_days_ir, treatment, days_treated, since_tx, bactopop, submodel, stage, dim, days_dry)   
    end

    # Add agents from the receiving container if this is not null
#=     if length(animalModel.receiving) != 0
        for i in 1:length(animalModel.receiving)
            agent = animalModel.receiving[i]
            newid = rand(1500:5000)
            while true
                haskey(animalModel.agents, newid)
                newid = rand(1500:5000)
                break
            end
            agent.id = newid 
            println(newid)
            add_agent!(agent, animalModel)
        end
 =#

#end
end

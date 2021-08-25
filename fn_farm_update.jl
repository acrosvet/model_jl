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
            push!(farmModel[id].animalModel.sending, traded_agent)
        end

    # Trade infection between farms 

    trade_partners = node_neighbors(FarmAgent, farmModel)

    if typeof(trade_partners) == Nothing && return
    else
        trade_partner = rand(1:length(trade_partners))
        farmModel[trade_partner].animalModel.receiving = farmModel[id].animalModel.sending

        if length(farmModel[trade_partner].animalModel.receiving) > 0

        for i in 1:length(farmModel[trade_partner].animalModel.receiving)
#=             vel = farmModel[trade_partner].animalModel.receiving[i].vel
            age = farmModel[trade_partner].animalModel.receiving[i].age
            status = farmModel[trade_partner].animalModel.receiving[i].status
            βₛ = farmModel[trade_partner].animalModel.receiving[i].βₛ
            βᵣ = farmModel[trade_partner].animalModel.receiving[i].βᵣ
            inf_days_is = farmModel[trade_partner].animalModel.receiving[i].inf_days_is
            inf_days_ir = farmModel[trade_partner].animalModel.receiving[i].inf_days_ir
            treatment = farmModel[trade_partner].animalModel.receiving[i].treatment
            days_treated = farmModel[trade_partner].animalModel.receiving[i].days_treated
            since_tx = farmModel[trade_partner].animalModel.receiving[i].since_tx
            bactopop = farmModel[trade_partner].animalModel.receiving[i].bactopop
            submodel = farmModel[trade_partner].animalModel.receiving[i].submodel
            stage = farmModel[trade_partner].animalModel.receiving[i].stage
            dim = farmModel[trade_partner].animalModel.receiving[i].dim
            days_dry = farmModel[trade_partner].animalModel.receiving[i].days_dry =#
            agent = farmModel[trade_partner].animalModel.receiving[i]
            add_agent!(agent, farmModel[trade_partner].animalModel)
            
        end
        println(length(farmModel[trade_partner].animalModel.agents))
    else
        return
    end
    end    

    
    end
    
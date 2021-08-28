function model_step!(animalModel)
    #Define the proximity for which infection may occur
    birth!(animalModel)
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

    has_stage(AnimalAgent, status) = AnimalAgent.status == status
        
    is_traded(status) = AnimalAgent -> has_stage(AnimalAgent, status) 
    
    traded_agent = random_agent(animalModel, is_traded(:S))

   # println(traded_agent)
    println(typeof(traded_agent))

    animalModel.sending = []

    push!(animalModel.sending, traded_agent)

    println(length(animalModel.sending))

    kill_agent!(traded_agent.id, animalModel)
    

    
end


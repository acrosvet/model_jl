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

    num_traded = rand(1:24)

    animalModel.sending = []


    for animal in 1:num_traded
            
        traded_agent = random_agent(animalModel, is_traded(:S))

        push!(animalModel.sending, traded_agent)

        if haskey(animalModel.agents, traded_agent) == true

            kill_agent!(traded_agent, animalModel)
        else
            return
        end
    end        

    println(length(animalModel.sending))

end


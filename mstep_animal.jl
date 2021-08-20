function model_step!(animalModel)
    #Define the proximity for which infection may occur
    birth!(animalModel)
    r = animalModel.animalProximityRadius
    for (a1,a2) in interacting_pairs(animalModel, r, :nearest)
        elastic_collision!(a1, a2) #Collison dynamics for each animal
        transmit_sensitive!(a1,a2) #Sensitive transmission function
        transmit_resistant!(a1,a2) #Resistant transmission function
        transmit_carrier_is!(a1,a2)
        transmit_carrier_ir!(a1,a2)
        
    end


    if animalModel.calday > 365
        animalModel.calday = 0
    else
        animalModel.calday = animalModel.calday
    end

    animalModel.calday += 1

    
end


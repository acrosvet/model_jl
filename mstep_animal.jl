"""
model_step!(animalModel)

* Stepping function, progress the animal model over time by:
    - Transmitting infections between animals
    - Having animals born into the population
    - Incrementing the calendar day
    - Trading agents between farms

* Calls the following functions:
- birth!
- daytrader!
- transmit_sensitive!
- transmit_resistant!
- transmit_carrier_is!
- transmit_carrier_ir!

"""
function model_step!(animalModel)

    #Define the proximity for which infection may occur

    r = animalModel.animalProximityRadius

    # Set up interactions and transmission events between animal agents using billiard ball dynamics
    for (a1,a2) in interacting_pairs(animalModel, r, :nearest)
        elastic_collision!(a1, a2) #Collison dynamics for each animal
        transmit_sensitive!(a1,a2, animalModel) #Sensitive transmission function
        transmit_resistant!(a1,a2, animalModel) #Resistant transmission function
        transmit_carrier_is!(a1,a2, animalModel) #Transmit carrier states (sensitive)
        transmit_carrier_ir!(a1,a2, animalModel) #Transmit carrier states (resistant)
        
    end

    # Reset the number of days for each year at the start of a new year
    if animalModel.calday > 364
        animalModel.calday = 0
        animalModel.model_year += 1
    else
        animalModel.calday = animalModel.calday
    end
    # Increment the year by one day
    animalModel.calday += 1

    # Trade animals between farms using the daytrader function
    daytrader!(FarmAgent, animalModel)

    #Determine trading need

    trading_need!(animalModel)

    
end

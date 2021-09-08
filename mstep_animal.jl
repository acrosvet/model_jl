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

        # Increment the date by one day

        animalModel.date += Day(1)

        # Increment the model step
        animalModel.step +=1
    

    # Increment psc

    if Year(animalModel.date) > Year(animalModel.psc)
        animalModel.psc += Year(1)
    end

    # Increment msd 

    if Year(animalModel.date) > Year(animalModel.msd)
        animalModel.msd += Year(1)
    end
    


    # Trade animals between farms using the daytrader function
    #daytrader!(FarmAgent, animalModel)

    #Determine trading need

    trading_need!(animalModel)


    
end

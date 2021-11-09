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

    # Update bacterial population ----------


    update_bactopop!(animalModel)



    stock_numbers!(animalModel)#
    trading_need!(animalModel)
    send_trades!(animalModel)
    
        # Increment the date by one day

        animalModel.date += Day(1)

        # Increment the model step
        animalModel.step +=1
    

update_psc!(animalModel)
update_msd!(animalModel)

end


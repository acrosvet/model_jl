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

    Threads.@threads for i in 1:length(animalModel.agents)
        if haskey(animalModel.agents, i)
            num_sense = [a.status == :IS for a in allagents(animalModel[i].submodel)]
            num_sense = sum(num_sense)/length(animalModel[i].submodel.agents)
            animalModel[i].bactopop_is = num_sense


            num_res = [a.status == :R for a in allagents(animalModel[i].submodel)]
            num_res = sum(num_res)/length(animalModel[i].submodel.agents)
            animalModel[i].bactopop_r = num_res


        end
    end

     for a in collect(allagents(animalModel))
        
        #Threads.@spawn begin 
            a.submodel.rng = MersenneTwister(hash(a))
            @async Threads.@spawn step!(a.submodel, bact_agent_step!, bact_model_step!, 1)
        #end
    end


    stock_numbers!(animalModel)
    trading_need!(animalModel)
    send_trades!(animalModel)
    
        # Increment the date by one day

        animalModel.date += Day(1)

        # Increment the model step
        animalModel.step +=1
    

# Increment psc ---------------------------------------------------
if animalModel.system != :Continuous
    if Year(animalModel.date) > Year(animalModel.psc)
        animalModel.psc += Year(1)
    end

if animalModel.system == :Split || animalModel.system == :Batch
    if Year(animalModel.date) > Year(animalModel.psc_2)
        animalModel.psc_2 += Year(1)
    end
end

if animalModel.system == :Batch
    if Year(animalModel.date) > Year(animalModel.psc_3)
        animalModel.psc_3 += Year(1)
    end

    if Year(animalModel.date) > Year(animalModel.psc_4)
        animalModel.psc_4 += Year(1)
    end
end

# Increment msd ---------------------------------------------

    if Year(animalModel.date) > Year(animalModel.msd)
        animalModel.msd += Year(1)
    end

if animalModel.system == :Split || animalModel.system == :Batch
    if Year(animalModel.date) > Year(animalModel.msd_2)
        animalModel.msd_2 += Year(1)
    end
end

if animalModel.system == :Batch
    if Year(animalModel.date) > Year(animalModel.msd_3)
        animalModel.msd_3 += Year(1)
    end

    if Year(animalModel.date) > Year(animalModel.msd_4)
        animalModel.msd_4 += Year(1)
    end
end
end
end


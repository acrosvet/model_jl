function update_agent!(AnimalAgent)
    AnimalAgent.age += 1 # Increment age by 1 day
    
    if AnimalAgent.treatment == :T 
        AnimalAgent.days_treated += 1
    elseif AnimalAgent.treatment == :PT
        AnimalAgent.since_tx += 1
    end

    # Change stage over time ------------------------
    if AnimalAgent.age < 60
        AnimalAgent.stage = :C
    elseif AnimalAgent.age ≥ 60 && AnimalAgent.age ≤ 13*30
        AnimalAgent.stage = :W
    elseif AnimalAgent.age > 13*30 && AnimalAgent.age ≤ 24*30
        AnimalAgent.stage = :H
    elseif AnimalAgent.age > 24*30 && AnimalAgent.stage != :D
        AnimalAgent.stage = :L 
    elseif AnimalAgent.stage == :D && AnimalAgent.days_dry > rand(60:90)
        AnimalAgent.dim = 0
        AnimalAgent.days_dry = 0
    end

    #Increase dim --------------------

    if AnimalAgent.stage == :L 
        AnimalAgent.dim += 1
    else
        AnimalAgent.dim = AnimalAgent.dim
    end

    # Dryoff -------------------

    if AnimalAgent.stage == :L && AnimalAgent.dim > (rand(305:400))
        AnimalAgent.stage = :D
        AnimalAgent.days_dry += 1
    else
        AnimalAgent.stage = AnimalAgent.stage
    end

    if AnimalAgent.stage == :D
        AnimalAgent.days_dry += 1
    else
        return
    end

    # Calve ----------------------

    if AnimalAgent.stage == :D && AnimalAgent.days_dry > (rand(60:90))
        AnimalAgent.stage = :L
        AnimalAgent.dim = 0
    else
        return
    end

    


    # Add in bacterial data output
    resistant(x) = count(i == :R for i in x)
    sensitive(x) = count(i == :IS for i in x)
    susceptible(x) = count(i == :S for i in x)
    adata = [
    (:status, resistant),
    (:status, sensitive),
    (:status, susceptible)
    ]

    # Bacterial population of uninfected animals ----------------------

function uninfected!(BacterialAgent, bacterialModel)

    if bacterialModel.total_status == :S
        BacterialAgent.status = :S
    end

end


# Transmission of bacteria between individuals -----------------
    
    function bact_transfer_r!(BacterialAgent, bacterialModel)
        if bacterialModel.total_status == :ER
            bacterialModel.days_exposed += 1
        else return
        end
        
        if bacterialModel.total_status == :ER && bacterialModel.days_exposed == 1
            bacterialModel.r_strain = rand(1:bacterialModel.nstrains) 
            bacterialModel.strain == bacterialModel.rstrain ? BacterialAgent.status = :R : BacterialAgent.status = :S
        else return
        end


    end

    function bact_transfer_s!(BacterialAgent, bacterialModel)
        if bacterialModel.total_status == :ES
            bacterialModel.days_exposed += 1
        else return
        end
        
        if bacterialModel.total_status == :ES && bacterialModel.days_exposed == 1
            bacterialModel.r_strain = 0
            BacterialAgent.status == :IS
            bacterialModel.strain == bacterialModel.rstrain ? BacterialAgent.status = :R : BacterialAgent.status == :IS 
        else return
        end


    end


    function bact_plasmid_transfer!(BacterialAgent, bacterialModel)

        for neighbor in nearby_agents(BacterialAgent, bacterialModel)
            if BacterialAgent.status == :R && neighbor.status == :IS
                if rand(bacterialModel.rng) < 1e-6/time_units
                    neighbor.status = BacterialAgent.status
                    neighbor.strain = BacterialAgent.strain
                    
                end
            end
        end
    end

    function bact_treatment_response!(BacterialAgent, bacterialModel)

        res = bact_response(bacterialModel)/time_units

        if (bacterialModel.days_treated > 0 && BacterialAgent.status == :IS)
            if res/100 > rand(bacterialModel.rng)
                        BacterialAgent.status = :R
                        BacterialAgent.strain = bacterialModel.r_strain
                    end
       else 
                    return
        end



    end




    # Define the agent updating function

    # Define the treatment response function

    function bact_response(bacterialModel)
        timevar = (bacterialModel.days_treated)/time_units
        res = (100*ℯ^(-0.2/timevar))/(1 + ℯ^(-0.2/timevar))
        return res/time_units
    end

    # 

 
     #Update agent parameters for each timestep  
    function bact_update_agent!(BacterialAgent, bacterialModel)

    end 
    
    # Define the agent stepping function
    #Update agent parameters for each time step

    function bact_agent_step!(BacterialAgent, bacterialModel)
            uninfected!(BacterialAgent, bacterialModel)
            bact_transfer_r!(BacterialAgent, bacterialModel)
            bact_transfer_s!(BacterialAgent, bacterialModel)
            #fitness!(BacterialAgent, bacterialModel)
            bact_update_agent!(BacterialAgent, bacterialModel) #Apply the update_agent function
            bact_plasmid_transfer!(BacterialAgent, bacterialModel)
            bact_treatment_response!(BacterialAgent, bacterialModel)

    end


    bacterialModel = AnimalAgent.submodel
    bacterialModel.properties[:total_status] = AnimalAgent.status
    bacterialModel.properties[:days_treated] = AnimalAgent.days_treated
    bacterialModel.properties[:age] = AnimalAgent.age

    bactostep, _ = run!(bacterialModel, bact_agent_step!, 100; adata)

    sense = bactostep[:,:sensitive_status][2]
    res = bactostep[:,:resistant_status][2]
    sus = bactostep[:,:susceptible_status][2]
    prop_res = res/(sense + res)

    AnimalAgent.bactopop = prop_res
end

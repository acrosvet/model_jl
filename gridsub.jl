const time_units = 1



function initialisePopulation(

        nbact = 10000,
        seed = 42,
        status = :S,
        strain = 1,
        nstrains = 4,
        timestep = 1.0, #Set model timestep
        r_strain = rand(1:nstrains),
        fitness = 0, 
        days_treated = 0,
        age = 0,
        total_status = :S,
        days_exposed = 0,
    )
    agentSpace = GridSpace((100, 100); periodic = false)
    #agentSpace = ContinuousSpace((1,1), 1; periodic = true)

    bactproperties = @dict(
        nbact,
        seed,
        status,
        nstrains,
        strain,
        timestep,
        r_strain,
        days_treated,
        total_status,
        fitness,
        age,
        days_exposed,
    )

    bacterialModel = ABM(BacterialAgent, agentSpace, properties = bactproperties, rng = MersenneTwister(seed))

    # strain fitness

    function bact_fitness()
        rand(2:7)/10
    end

    # Set up the initial parameters
    for n in 1:nbact
        r_strain = total_status == :IS ? 0 : r_strain
        strain = rand(1:nstrains)
        status = (strain == r_strain) ? :R : :IS
        pos = (1,1)
        fitness = [bact_fitness() for i in 1:strain]
        agent = BacterialAgent(n, pos,  status, strain)
        add_agent_single!(agent, bacterialModel)
    end

        return bacterialModel

end

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


const time_units = 24



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
        treatment_start = rand(0:100)*time_units,
        age = 0,

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
        treatment_start,
        fitness,
        age
    )

    bacterialModel = ABM(BacterialAgent, agentSpace, properties = bactproperties, rng = MersenneTwister(seed))

    # strain fitness

    function bact_fitness()
        rand(2:7)/10
    end

    # Set up the initial parameters
    for n in 1:nbact
        r_strain = r_strain
        strain = rand(1:nstrains)
        status = (strain == r_strain) ? :R : :S
        pos = (1,1)
        days_treated = days_treated
        treatment_start = treatment_start
        fitness = [bact_fitness() for i in 1:strain]
        agent = BacterialAgent(n, pos,  status, strain,  days_treated, age)
        add_agent_single!(agent, bacterialModel)
    end

        return bacterialModel

end


    function bact_plasmid_transfer!(BacterialAgent, bacterialModel)

        for neighbor in nearby_agents(BacterialAgent, bacterialModel)
            if BacterialAgent.status == :R && neighbor.status == :S
                if rand(bacterialModel.rng) < 0.001/time_units
                    neighbor.status = BacterialAgent.status
                    neighbor.strain = BacterialAgent.strain
                    
                end
            end
        end
    end

    function bact_treatment_response!(BacterialAgent, bacterialModel)

        res = response(BacterialAgent)/time_units

        if (BacterialAgent.days_treated > 0 && BacterialAgent.status == :S)
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

    function bact_response(BacterialAgent)
        timevar = (BacterialAgent.days_treated)/time_units
        res = (100*ℯ^(-0.2/timevar))/(1 + ℯ^(-0.2/timevar))
        return res/time_units
    end

    # 


    #Update agent parameters for each timestep  
    function bact_update_agent!(BacterialAgent)
        BacterialAgent.age = BacterialAgent.age + 1
        # Update the time treated
        if BacterialAgent.age ≥ bacterialModel.treatment_start
            BacterialAgent.days_treated += 1
        end


    end
        
    # Define the agent stepping function
    #Update agent parameters for each time step

    function bact_agent_step!(BacterialAgent, bacterialModel)
            #fitness!(BacterialAgent, bacterialModel)
            bact_update_agent!(BacterialAgent) #Apply the update_agent function
            bact_plasmid_transfer!(BacterialAgent, bacterialModel)
            bact_treatment_response!(BacterialAgent, bacterialModel)

    end

    resistant(x) = count(i == :R for i in x)
    sensitive(x) = count(i == :S for i in x)
    adata = [
    (:status, resistant),
    (:status, sensitive)
    ]
    bacterialModel = initialisePopulation()
    bactoSim = initialisePopulation()
    #=
    bactostep, _ = run!(bactoSim, bact_agent_step!; adata)

    sense = bactostep[:, dataname((:status, sensitive))][2]
    res = bactostep[:, dataname((:status, resistant))][2]

    prop_res = res/(sense + res)

    return prop_res
=#

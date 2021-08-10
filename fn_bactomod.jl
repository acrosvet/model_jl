mutable struct BacterialAgent <: AbstractAgent
    id::Int64
    pos::NTuple{2, Int}
    bactostatus::Symbol
    strain::Int64
    days_treated::Int
    age::Int
end

const time_units = 24



#include("packages.jl")
    ## Define the agents


    ## Define the model



    function initialiseBacteria(
        calfModel = calfModel,
        CalfAgent = CalfAgent,
        nbact = 10000,
        seed = 42,
        bactostatus = :S,
        strain = 1, 
        nstrains = 4,
        timestep = calfModel.timestep, #Set model timestep
        r_strain = rand(1:nstrains),
        fitness = 0, 
        days_treated = 0,
        treatment_start = rand(0:100)*time_units,
        age = CalfAgent.age,

    )
    bactoSpace = GridSpace((100, 100); periodic = false)
    #agentSpace = ContinuousSpace((1,1), 1; periodic = true)

    properties = @dict(
        nbact,
        seed,
        bactostatus,
        nstrains,
        strain,
        timestep,
        r_strain,
        days_treated,
        treatment_start,
        fitness,
        age
    )

    bacterialModel = ABM(BacterialAgent, bactoSpace, properties = properties, rng = MersenneTwister(seed))

    # strain fitness

    function bact_fitness()
        rand(2:7)/10
    end

    # Set up the initial parameters
    for n in 1:nbact
        r_strain = r_strain
        strain = rand(1:nstrains)
        bactostatus = (strain == r_strain) ? :R : :S
        pos = (1,1)
        days_treated = days_treated
        treatment_start = treatment_start
        fitness = [bact_fitness() for i in 1:strain]
        agent = BacterialAgent(n, pos,  bactostatus, strain,  days_treated, age)
        add_agent_single!(agent, bacterialModel)
    end

        return bacterialModel

    end

    bacterialModel = initialiseBacteria()


    function plasmid_transfer!(BacterialAgent, bacterialModel)

        for neighbor in nearby_agents(BacterialAgent, bacterialModel)
            if BacterialAgent.bactostatus == :R && neighbor.bactostatus == :S
                if rand(bacterialModel.rng) < 0.001/time_units
                    neighbor.bactostatus = BacterialAgent.bactostatus
                    neighbor.strain = BacterialAgent.strain
                    
                end
            end
        end
    end

    function treatment_response!(BacterialAgent, bacterialModel)

        res = response(BacterialAgent)/time_units

        if (BacterialAgent.days_treated > 0 && BacterialAgent.bactostatus == :S)
            if res/100 > rand(bacterialModel.rng)
                        BacterialAgent.bactostatus = :R
                        BacterialAgent.strain = bacterialModel.r_strain
                    end
       else 
                    return
        end



    end




    # Define the agent updating function

    # Define the treatment response function

    function response(BacterialAgent)
        timevar = (BacterialAgent.days_treated)/time_units
        res = (100*ℯ^(-0.2/timevar))/(1 + ℯ^(-0.2/timevar))
        return res/time_units
    end

    # 


    #Update agent parameters for each timestep  
    function update_bacteria!(BacterialAgent)
        BacterialAgent.age = BacterialAgent.age + 1
        # Update the time treated
        if BacterialAgent.age ≥ bacterialModel.treatment_start
            BacterialAgent.days_treated += 1
        end


    end
        
    # Define the agent stepping function
    #Update agent parameters for each time step

    function bacteria_step!(BacterialAgent, bacterialModel)
            #fitness!(BacterialAgent, bacterialModel)
            update_bacteria!(BacterialAgent) #Apply the update_agent function
            plasmid_transfer!(BacterialAgent, bacterialModel)
            treatment_response!(BacterialAgent, bacterialModel)

    end

    bactoSim = initialiseBacteria()

#=
    #Function, extract infected animals and susceptible animals at each timestep
    resistant(x) = count(i == :R for i in x)
    sensitive(x) = count(i == :S for i in x)

    adata = [
    (:bactostatus, resistant),
    (:bactostatus, sensitive)
    ]

    bactoSimRun, _ = run!(bactoSim, agent_step!, calfModel.timestep; adata)

    sensitive = bactoSimRun[:, dataname((:bactostatus, sensitive))]
    return(sensitive)
    =#

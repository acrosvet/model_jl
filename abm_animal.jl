# ABM - Animal  --------------------

  
    #Define model initialisation functions. 

    function initialiseModel(
        N::Int, #Default number of animals
        movement = 0.1, #Movement in continuous space
        βᵣ = 0.3/time_resolution, #Beta (resistant) 
        βₛ = 0.6/time_resolution, #Beta (sensitive)
        init_is = 5, # Number initially infected sensitive
        init_ir = 1, # Number initially infected resistant
        sponrec_is = 0.05/time_resolution, #chance of spontaneous recovery IS
        sponrec_ir = 0.04/time_resolution,  #chance of spontaneous recovery IR
        timestep = 1.0, #Set model timestep
        res_carrier = 0.05/time_resolution,
        sens_carrier = 0.01/time_resolution, 
        culling_rate = 0.3/time_resolution,
        calday = 365,
        model_year = 0,
        num_calves =  0,
        num_weaned =  Int(floor(N*0.125*rand(0.9:0.05:1.1))),
        num_heifers = Int(floor(N*0.125*rand(0.9:0.05:1.1))),
        num_lac = N - num_calves - num_weaned - num_heifers,
        rng = MersenneTwister(42); #Random seed 
        treatment_prob::Float64 = 0.3/time_resolution,
        treatment_duration::Int = 5*time_resolution,
        farm_id::Int = 1
    )
    #End header
    #Body

    #Define the agent space. At present, avoid observing pen boundaries.
    agentSpace = ContinuousSpace((100,100), 1; periodic = true) #Relatinship to real space?
    #Specify the disease dynamics  as a Dictionary to be passed to the model
    pathogenProperties = @dict(
        N, 
        animalProximityRadius = 0.5, #Radius for effective contact
        mortalityRateSens = 0.01/time_resolution, #Mort. (sensitive)
        mortalityRateRes = 0.015/time_resolution, #Mort. (resistant)
        βᵣ,
        βₛ,
        movement,
        timestep,
        sponrec_ir,
        sponrec_is,
        timestep, 
        treatment_prob,
        treatment_duration, 
        res_carrier,
        sens_carrier,
        calday,
        model_year,
        rng,
        culling_rate,
        herd_size = N,
        sending = [], # Agent sending container
        receiving = [], # Agent receiving container
        tradeable_heifers = 0, #Initial number of tradeable heifers
        tradeable_calves = 0, # Ibid, calves
        tradeable_lactating = 0, # Ibid, lactating
        tradeable_weaned = 0, # Ibid, weand
        tradeable_stock = 0, # Ibid, all stock
        farm_id,
 )# Dictionary of disease properties

    # Define the model: Agent type, agent space, properties, and type of random seed
    animalModel = ABM(AnimalAgent, agentSpace, properties = pathogenProperties)
    
    # Set the initial age of the animals
    function initial_age(n)
        if n <= num_calves
            #rand(truncated(Poisson(112), 49, 109))
        elseif (n > (num_calves + 1)) && (n <= (num_calves + num_weaned))
            rand(truncated(Poisson(112), 49, 109))
        elseif (n > (num_calves + num_weaned + 1 )) && (n <= (num_calves + num_weaned + num_heifers))
            rand(truncated(Poisson(477), 414, 474))   
        else (n > (num_calves + num_weaned + num_heifers + 1)) && (n <= (num_calves + num_weaned + num_heifers + num_lac))
           # rand(truncated(Poisson(floor(8*365)), 2*365, 8*365))
            rand(truncated(Poisson(5*365),(2*365), (8*365)))
        end
    end

    # Set the initial dim

    function initial_dim(stage)
    
        if stage == :L 
            rand(truncated(Poisson(112), 49, 109))
        else
            0
        end

    end

    # Set the initial lifestage 

    function initial_stage(n)
        
        if n <= num_calves
            :C
        elseif (n > (num_calves + 1)) && (n <= (num_calves + num_weaned))
            :W
        elseif n > (num_calves + num_weaned + 1 ) && n <= (num_calves + num_weaned + num_heifers)
            :H  
        else n > (num_calves + num_weaned + num_heifers + 1) && n <= (num_calves + num_weaned + num_heifers + num_lac)
            :L
        end
        
    end

    #Define a function to set initial infected status. This gets supplied to the loop describing the initial system state.
    function initial_status(n, init_ir, init_is)
        if n ≤ init_is 
            :IS
        elseif n > init_is && n <= (init_is + init_ir)
            :IR
        elseif n > init_is + init_ir
            :S
        end
    end

    #Define a function parameter to govern the movement of animals in different states

    function initial_velocity(status, movement)
        if status == :S
            sincos(2π*rand(animalModel.rng)) .*movement
        elseif status == :IS
            sincos(2π*rand(animalModel.rng)) .*(movement/2)
        elseif status == :IR
            sincos(2π*rand(animalModel.rng)) .*(movement/2.5)
        elseif status == :M
            (0.0,0.0)
        end
    end

    function initial_pregstat(stage, age, dim)

        if stage == :H 
            lambda = 13*30 + 21
            lower = 13*30 + 21
            upper = 13*30 + 120
            if age ≥ rand(truncated(Poisson(lambda),lower, upper))
                if rand(animalModel.rng) > 0.5
                    return :P
                end    
            end
        elseif stage == :L && dim >= rand(truncated(Poisson(142),110, 215))
            return :P
        else
            return :E
        end
    end


    #Define the initial state of the system. Attributes for each animal in the system.
    for n in 1:N
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = Tuple(10*rand(animalModel.rng, 2))
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
        age = initial_age(n) # Defined using initial age function
        βᵣ = βᵣ 
        βₛ = βₛ
        treatment = :U #Default agent is untreated
        treatment_prob = treatment_prob
        days_treated = 0 # Default is not treated
        treatment_duration = treatment_duration #Passed argument
        bactopop = 0.0
        since_tx = 0 # Default 0 
        inf_days = 0
        agenttype = :Initial
       # inf_days_ir = 0
        submodel = initialisePopulation(
            nbact = 100,
            total_status = status,
            timestep = timestep,
            days_treated = 0,
            age = age,
            days_exposed = 0
        )
        vel = initial_velocity(status, movement) #Defined using initial velocity fn
        stage = initial_stage(n) # Defined using initial stage fn
        dim = initial_dim(stage) # Defined using initial dim fn
        days_dry = 0 # Default 0
        days_exposed = 0 # Default 0 
        days_carrier = 0 # Default 0 
        trade_status = false
        lactation = stage == :L ? 1 : 0
        pregstat = initial_pregstat(stage, age, dim)
        add_agent!(pos, animalModel, vel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat)
    
    end

        return animalModel

    end


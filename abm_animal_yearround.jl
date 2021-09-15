# ABM - Animal  --------------------

  
    #Define model initialisation functions. 

    function initialiseContinuous(
        N::Int, #Default number of animals
        movement = 0.1, #Movement in continuous space
        βᵣ = 0.3, #Beta (resistant) 
        βₛ = 0.6, #Beta (sensitive)
        init_is = 5, # Number initially infected sensitive
        init_ir = 1, # Number initially infected resistant
        sponrec_is = 0.05, #chance of spontaneous recovery IS
        sponrec_ir = 0.04,  #chance of spontaneous recovery IR
        timestep = 1.0, #Set model timestep
        res_carrier = 0.05, #Probability of becoming a resistant carrier
        sens_carrier = 0.01, #Probability of becoming a sensitive carrier
        culling_rate = 0.3, #Culling rate
        num_lac = N, #Initial number of lactating cows
        num_heifers = floor(0.3*N),
        num_weaned = floor(0.3*N),
        rng = MersenneTwister(42); #Random seed 
        treatment_prob::Float64 = 0.3, #Treatment probability, passed from farmModel
        treatment_duration::Int = 5, #Treatment duration, passed from farmModel
        farm_id::Int = 1, #Farm ID (from FarmModel)
        system::Symbol = :Continuous,
        step::Int = 1, #Model step
        date::Date = Date(2021, 7, 2) #Model start date

    )
    #End header
    #Body

    #Define the agent space. At present, avoid observing pen boundaries.
    agentSpace = ContinuousSpace((100,100), 1; periodic = true) #Relatinship to real space?
    
    #Specify the disease dynamics  as a Dictionary to be passed to the model
    pathogenProperties = @dict(
        N, 
        animalProximityRadius = 0.5, #Radius for effective contact
        mortalityRateSens = 0.01, #Mort. (sensitive)
        mortalityRateRes = 0.015, #Mort. (resistant)
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
        num_lac,
        num_weaned,
        num_heifers,
        step,
        date,
        current_lac = 0,
        system,
 )# Dictionary of disease properties

    # Define the model: Agent type, agent space, properties, and type of random seed
    animalModel = ABM(AnimalAgent, agentSpace, properties = pathogenProperties)

    # Set the initial dim
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


# Add the lactating cows ---------------------------------------------------

    #Define the initial state of the system. Attributes for each animal in the system.
    for n in 1:N
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = Tuple(10*rand(animalModel.rng, 2))
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
        age = Int(floor(rand(truncated(Rayleigh(5*365),(2*365), (8*365))))) # Defined using initial age function
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
        stage = :L #Initial stage
        dim =  Int(floor(rand(animalModel.rng, Uniform(1,305))))
        days_dry = 0 # Default 0
        days_exposed = 0 # Default 0 
        days_carrier = 0 # Default 0 
        trade_status = false #Eligibility for trading 
        lactation = round(age/365) - 1 #Lactation number
        pregstat = :P
        dic = Int(floor(rand(animalModel.rng, Uniform(1,283))))
        heat = false #If animal is in oestrus
        sex = :F #Sex of initial animals (always F)
        calving_season = :Continuous
        days_recovered = 0
        add_agent!(pos, animalModel, vel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, heat, sex, calving_season, days_recovered)
    
    end

    # Add the heifers ---------------------------------------------------

    #Define the initial state of the system. Attributes for each animal in the system.
    for n in 1:floor(N*0.25)
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = Tuple(10*rand(animalModel.rng, 2))
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
        age = Int(floor(rand(Uniform((20*28), (24*28))))) # Defined using initial age function
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
        stage = :DH #Initial stage
        dim =  0
        days_dry = 0 # Default 0
        days_exposed = 0 # Default 0 
        days_carrier = 0 # Default 0 
        trade_status = false #Eligibility for trading 
        lactation = round(age/365) - 1 #Lactation number
        pregstat = :P
        dic = Int(floor(rand(animalModel.rng, Uniform(1,283))))
        heat = false #If animal is in oestrus
        sex = :F #Sex of initial animals (always F)
        calving_season = :Continuous
        days_recovered = 0
        add_agent!(pos, animalModel, vel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, heat, sex, calving_season, days_recovered)
    
    end

     #Define the initial state of the system. Attributes for each animal in the system.
     for n in 1:floor(N*0.25)
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = Tuple(10*rand(animalModel.rng, 2))
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
        age = Int(floor(rand(Uniform((90), (380))))) # Defined using initial age function
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
        stage = :W #Initial stage
        dim =  0
        days_dry = 0 # Default 0
        days_exposed = 0 # Default 0 
        days_carrier = 0 # Default 0 
        trade_status = false #Eligibility for trading 
        lactation = round(age/365) - 1 #Lactation number
        pregstat = :E
        dic = 0
        heat = false #If animal is in oestrus
        sex = :F #Sex of initial animals (always F)
        calving_season = :Continuous
        days_recovered = 0
        add_agent!(pos, animalModel, vel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, heat, sex, calving_season, days_recovered)
    
    end

    #Define the initial state of the system. Attributes for each animal in the system.
    for n in 1:floor(N*0.25)
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = Tuple(10*rand(animalModel.rng, 2))
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
        age = Int(floor(rand(Uniform((0), (55))))) # Defined using initial age function
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
        stage = :C #Initial stage
        dim =  0
        days_dry = 0 # Default 0
        days_exposed = 0 # Default 0 
        days_carrier = 0 # Default 0 
        trade_status = false #Eligibility for trading 
        lactation = round(age/365) - 1 #Lactation number
        pregstat = :E
        dic = 0
        heat = false #If animal is in oestrus
        sex = :F #Sex of initial animals (always F)
        calving_season = :Continuous
        days_recovered =  0
        add_agent!(pos, animalModel, vel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, heat, sex, calving_season, days_recovered)
    
    end
        return animalModel

    end


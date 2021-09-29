
  
    #Define model initialisation functions. 

    function initialiseSeasonal(
        N::Int, #Default number of animals
        movement = 0.1, #Movement in continuous space
        βᵣ = 0.4, #Beta (resistant) 
        βₛ = 0.4, #Beta (sensitive)
        sponrec_is = 0.05, #chance of spontaneous recovery IS
        sponrec_ir = 0.04,  #chance of spontaneous recovery IR
        timestep = 1.0, #Set model timestep
        res_carrier = 0.05, #Probability of becoming a resistant carrier
        sens_carrier = 0.01, #Probability of becoming a sensitive carrier
        culling_rate = 0.3, #Culling rate
        num_lac = N, #Initial number of lactating cows
        num_heifers = floor(0.3*N),
        num_weaned = floor(0.3*N);
        #rng = MersenneTwister(42); #Random seed 
        treatment_prob::Float64 = 0.3, #Treatment probability, passed from farmModel
        treatment_duration::Int = 5, #Treatment duration, passed from farmModel
        farm_id::Int = FarmAgent.id, #Farm ID (from FarmModel)
        system::Symbol = :Seasonal,
        step::Int = 1, #Model step
        date::Date = Date(2021, 7, 2), #Model start date
        psc::Date = Date(2021, 7, 3), #Planned Start of Calving,
        msd::Date = Date(2021, 9, 24), #Mating Start Date
        nbact::Int = 10000,
        seed::Int = FarmAgent.id,
        dim::Int = 100,
        farm_status::Symbol = FarmAgent.status
    )
    #End header
    #Body

    #Define the agent space. At present, avoid observing pen boundaries.
    agentSpace =  GridSpace((100, 100, 10); periodic = false) 
    
    #Specify the disease dynamics  as a Dictionary to be passed to the model
    pathogenProperties = @dict(
        N, 
        #animalProximityRadius = 0.5, #Radius for effective contact
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
        rng = MersenneTwister(seed),
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
        num_calves = 0,
        step,
        date,
        psc,
        msd,
        current_lac = 0,
        current_weaned = 0,
        current_dh = 0,
        current_heifers = 0,
        current_dry = 0,
        current_calves = 0,
        system,
        nbact,
        seed, 
        dim,
        farm_status,
 )# Dictionary of disease properties

    # Define the model: Agent type, agent space, properties, and type of random seed
    animalModel = ABM(AnimalAgent, agentSpace, properties = pathogenProperties)
    
    function init_infected_r(farm_status, N)
        if farm_status == :S
            return 0
        elseif farm_status == :R
            return Int(floor(N*(rand(0.05:0.05:0.15))))
        elseif farm_status == :IS
            return 0
        end
    end

    function init_infected_is(farm_status, N)
        if farm_status == :S
            return Int(floor(n*(rand(0.0:0.01:0.05))))
        elseif farm_status == :R
            return Int(floor(N*(rand(0.0:0.01:0.05))))
        elseif farm_status == :IS
            return Int(floor(N*(rand(0.05:0.01:0.1))))
        end
    end

    init_ir = init_infected_r(farm_status, N)
    init_is = init_infected_is(farm_status, N)

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

# Add the lactating cows ---------------------------------------------------
    num_lac = N- num_heifers
    #Define the initial state of the system. Attributes for each animal in the system.
    for n in 1:(N - num_heifers)
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = (rand(animalModel.rng, 1:Int(floor(6*√num_lac)), 2)..., 5)
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
        age = Int(floor(rand(truncated(Rayleigh(5*365),(2*365), (8*365))))) # Defined using initial age function
        βᵣ = βᵣ 
        βₛ = βₛ
        treatment = :U #Default agent is untreated
        treatment_prob = treatment_prob
        days_treated = 0 # Default is not treated
        treatment_duration = treatment_duration #Passed argument
        bactopop_r = 0.0
        bactopop_is = 0.0
        since_tx = 0 # Default 0 
        inf_days = 0
        agenttype = :Initial
       # inf_days_ir = 0

        stage = :D #Initial stage
        dim = 0 # Defined using initial dim fn
        days_dry = 0 # Default 0
        days_exposed = 0 # Default 0 
        days_carrier = 0 # Default 0 
        trade_status = false #Eligibility for trading 
        lactation = round(age/365) - 1 #Lactation number
        pregstat = :P #Initial pregnancy status
        dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(240), 199, 290)))) #Gives a 63% ICR for this rng
        stress = false #If animal is in oestrus
        sex = :F #Sex of initial animals (always F)
        calving_season = :Spring
        days_recovered = 0
        submodel =  initialiseBacteria(
            nbact = nbact,
            total_status = status,
            timestep = 1.0,
            age = age,
            days_treated = days_treated,
            days_exposed = days_exposed,
            days_recovered = days_recovered,
            stress = false,
            animalno = 0,
            dim = dim
        )
        if isempty(pos, animalModel)
            add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
        end
    end

    # Add the heifers ---------------------------------------------------

   for n in 1:num_heifers
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = (rand(animalModel.rng, 1:Int(floor(7*√num_heifers)), 2)..., 4)
        status = :S # Defined using initial status function
        age = Int(floor(rand(truncated(Rayleigh(2*365),(22*30), (25*30))))) # Defined using initial age function
        βᵣ = βᵣ 
        βₛ = βₛ
        treatment = :U #Default agent is untreated
        treatment_prob = treatment_prob
        days_treated = 0 # Default is not treated
        treatment_duration = treatment_duration #Passed argument
        bactopop_r = 0.0
        bactopop_is = 0.0
        since_tx = 0 # Default 0 
        inf_days = 0
        agenttype = :Initial
       # inf_days_ir = 0

        stage = :DH #Initial stage
        dim = 0 # Defined using initial dim fn
        days_dry = 0 # Default 0
        days_exposed = 0 # Default 0 
        days_carrier = 0 # Default 0 
        trade_status = false #Eligibility for trading 
        lactation = round(age/365) - 1 #Lactation number
        pregstat = :P #Initial pregnancy status
        dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(260), 199, 290)))) #Gives a 63% ICR for this rng
        stress = false #If animal is in oestrus
        sex = :F #Sex of initial animals (always F)
        calving_season = :Spring
        days_recovered = 0
        submodel = initialiseBacteria(
            nbact = nbact,
            total_status = status,
            timestep = 1.0,
            age = age,
            days_treated = days_treated,
            days_exposed = days_exposed,
            days_recovered = days_recovered,
            stress = false,
            animalno = 0,
            dim = dim
        )
        if isempty(pos, animalModel)
            add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
        end
    end

    # Add weaned ---------------------------------------------------------------------------
    for n in 1:num_weaned
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = (rand(animalModel.rng, 1:Int(floor(7*√num_weaned)), 2)..., 2)
        status = :S # Defined using initial status function
        age = Int(floor(rand(truncated(Rayleigh(365),(295), (385))))) # Defined using initial age function
        βᵣ = βᵣ 
        βₛ = βₛ
        treatment = :U #Default agent is untreated
        treatment_prob = treatment_prob
        days_treated = 0 # Default is not treated
        treatment_duration = treatment_duration #Passed argument
        bactopop_r = 0.0
        bactopop_is = 0.0
        since_tx = 0 # Default 0 
        inf_days = 0
        agenttype = :Initial
       # inf_days_ir = 0

        stage = :W #Initial stage
        dim = 0 # Defined using initial dim fn
        days_dry = 0 # Default 0
        days_exposed = 0 # Default 0 
        days_carrier = 0 # Default 0 
        trade_status = false #Eligibility for trading 
        lactation = round(age/365) - 1 #Lactation number
        pregstat = :E #Initial pregnancy status
        dic = 0
        stress = false #If animal is in oestrus
        sex = :F #Sex of initial animals (always F)
        calving_season = :Spring
        days_recovered = 0
        submodel =  initialiseBacteria(
            nbact = nbact,
            total_status = status,
            timestep = 1.0,
            age = age,
            days_treated = days_treated,
            days_exposed = days_exposed,
            days_recovered = days_recovered,
            stress = false,
            animalno = 0,
            dim = dim
        )
        if isempty(pos, animalModel)
            add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
        end    
    end
    
    animalModel.herd_size = N*1.5

        return animalModel

    end


# ABM - Animal  --------------------

  
    #Define model initialisation functions. 

    function initialiseBatch(
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
        num_heifers = floor(0.3*N)*0.5,
        num_weaned = floor(0.3*N)*0.5;
        #rng = MersenneTwister(42); #Random seed 
        treatment_prob::Float64 = 0.3, #Treatment probability, passed from farmModel
        treatment_duration::Int = 5, #Treatment duration, passed from farmModel
        farm_id::Int = 1, #Farm ID (from FarmModel)
        system::Symbol = :Batch,
        step::Int = 1, #Model step
        date::Date = Date(2021, 7, 2), #Model start date
        psc::Date = Date(2021, 7, 3), #Planned Start of Calving,
        msd::Date = Date(2021, 9, 24), #Mating Start Date
        psc_2::Date = (psc + Month(3)), #Second calving
        psc_3::Date = (psc - Month(6)), # Third calving
        psc_4::Date = (psc - Month(3)), 
        msd_2::Date = (msd + Month(3)), #Second joining
        msd_3::Date = (msd - Month(6)),
        msd_4::Date = (msd - Month(3)),
        nbact::Int = 10000,
        seed::Int = FarmAgent.id,
        dims::Int = 100
    )
    #End header
    #Body

    #Define the agent space. At present, avoid observing pen boundaries.
    agentSpace =  GridSpace((100, 100, 10); periodic = false) 
    
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
        rng =  MersenneTwister(seed),
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
        psc,
        psc_2,
        psc_3,
        psc_4,
        msd,
        msd_2, 
        msd_3,
        msd_4,
        current_lac = 0,
        current_weaned = 0,
        current_dh = 0,
        current_heifers = 0,
        current_dry = 0,
        current_calves = 0,
        system,
        lac_batch = floor(N*0.25),
        current_b1 = 0,
        current_b2 = 0,
        current_b3 = 0,
        current_b4 = 0,
        nbact,
        seed,
        dims
 )# Dictionary of disease properties

    # Define the model: Agent type, agent space, properties, and type of random seed
    animalModel = ABM(AnimalAgent, agentSpace, properties = pathogenProperties)

# Utilty functions -------------------------------------------------------

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


# Calving period one --------------------------------------------------------
    #Define the initial state of the system. Attributes for each animal in the system.
    for n in 1:floor(N*0.25*0.7)
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = (rand(animalModel.rng, 1:100, 2)..., 6)
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
        stage = :D #Initial stage
        dim = 0 # Defined using initial dim fn
        days_dry = 0 # Default 0
        days_exposed = 0 # Default 0 
        days_carrier = 0 # Default 0 
        trade_status = false #Eligibility for trading 
        lactation = round(age/365) - 1 #Lactation number
        pregstat = :P #Initial pregnancy status
        dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(262), 199, 283)))) #Gives a 63% ICR for this rng
        stress = false #If animal is in oestrus
        sex = :F #Sex of initial animals (always F)
        calving_season = :B1
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
            dims = dims
        )
        if isempty(pos, animalModel)
            add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
        end
    end

    # Add the heifers ---------------------------------------------------

    for n in 1:floor(N*0.25*0.3)
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = (rand(animalModel.rng, 1:100, 2)..., 4)
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
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
        stage = :DH #Initial stage
        dim = 0 # Defined using initial dim fn
        days_dry = 0 # Default 0
        days_exposed = 0 # Default 0 
        days_carrier = 0 # Default 0 
        trade_status = false #Eligibility for trading 
        lactation = round(age/365) - 1 #Lactation number
        pregstat = :P #Initial pregnancy status
        dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(272), 199, 283)))) #Gives a 63% ICR for this rng
        stress = false #If animal is in oestrus
        sex = :F #Sex of initial animals (always F)
        calving_season = :B1
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
            dims = dims
        )
        if isempty(pos, animalModel)
            add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
        end
    end

    # Add weaned ---------------------------------------------------------------------------
    for n in 1:floor(N*0.25*0.25)
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = (rand(animalModel.rng, 1:100, 2)..., 2)
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
        age = Int(floor(rand(truncated(Rayleigh(315),(281), (365))))) # Defined using initial age function
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
        calving_season = :B1
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
            dims = dims
        )
        if isempty(pos, animalModel)
            add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
        end
    end


# Calving period two --------------------------------------------------------
    #Define the initial state of the system. Attributes for each animal in the system.
    for n in 1:floor(N*0.25)
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = (rand(animalModel.rng, 1:100, 2)..., 5)
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
        age = Int(floor(rand(truncated(Rayleigh(4*365),(2*365), (8*365))))) # Defined using initial age function
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
        stage = :L #Initial stage
        dim = Int(floor(rand(animalModel.rng, truncated(Rayleigh(237), 189, 273)))) # Defined using initial dim fn
        days_dry = 0 # Default 0
        days_exposed = 0 # Default 0 
        days_carrier = 0 # Default 0 
        trade_status = false #Eligibility for trading 
        lactation = round(age/365) - 1 #Lactation number
        pregstat =  rand(animalModel.rng) < 0.85 ? :P : :E # 85% in calf
        dic = pregstat == :P ? Int(floor(rand(animalModel.rng, truncated(Rayleigh(153), 85, 188)))) : 0
        stress = false #If animal is in oestrus
        sex = :F #Sex of initial animals (always F)
        calving_season = :B2
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
            dims = dims
        )
        if isempty(pos, animalModel)
            add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
        end
    end

    # Add the heifers ---------------------------------------------------

    for n in 1:floor(N*0.25*0.25)
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = (rand(animalModel.rng, 1:100, 2)..., 4)
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
        age = Int(floor(rand(truncated(Rayleigh(603),553, 638)))) # Defined using initial age function
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
        stage = :DH #Initial stage
        dim = 0 # Defined using initial dim fn
        days_dry = 0 # Default 0
        days_exposed = 0 # Default 0 
        days_carrier = 0 # Default 0 
        trade_status = false #Eligibility for trading 
        lactation = round(age/365) - 1 #Lactation number
        pregstat = :P #Initial pregnancy status
        dic= Int(floor(rand(animalModel.rng, truncated(Rayleigh(174), 126, 209))))
        stress = false #If animal is in oestrus
        sex = :F #Sex of initial animals (always F)
        calving_season = :B2
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
            dims = dims
        )
        if isempty(pos, animalModel)
            add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
        end
    end

    # Add weaned ---------------------------------------------------------------------------
    for n in 1:floor(N*0.25*0.25)
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = (rand(animalModel.rng, 1:100, 2)..., 2)
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
        age = Int(floor(rand(animalModel.rng, truncated(Rayleigh(237), 189, 273)))) # Defined using initial age function
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
        calving_season = :B2
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
            dims = dims
        )
        if isempty(pos, animalModel)
            add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
        end
    end

# Calving period three --------------------------------------------------------
    #Define the initial state of the system. Attributes for each animal in the system.
    for n in 1:floor(N*0.25)
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = (rand(animalModel.rng, 1:100, 2)..., 5)
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
        age = Int(floor(rand(truncated(Rayleigh(4*365),(2*365), (8*365))))) # Defined using initial age function
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
        stage = :L #Initial stage
        dim = Int(floor(rand(animalModel.rng, truncated(Rayleigh(145), 97, 180)))) # Defined using initial dim fn
        days_dry = 0 # Default 0
        days_exposed = 0 # Default 0 
        days_carrier = 0 # Default 0 
        trade_status = false #Eligibility for trading 
        lactation = round(age/365) - 1 #Lactation number
        pregstat =  rand(animalModel.rng) < 0.85 ? :P : :E # 85% in calf
        dic = pregstat == :P ? Int(floor(rand(animalModel.rng, truncated(Rayleigh(61), 13, 96)))) : 0
        stress = false #If animal is in oestrus
        sex = :F #Sex of initial animals (always F)
        calving_season = :B3
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
            dims = dims
        )
        if isempty(pos, animalModel)
            add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
        end
    end

    # Add the heifers ---------------------------------------------------

    for n in 1:floor(N*0.25*0.25)
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = (rand(animalModel.rng, 1:100, 2)..., 4)
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
        age = Int(floor(rand(truncated(Rayleigh(511),463, 546)))) # Defined using initial age function
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
        stage = :DH #Initial stage
        dim = 0 # Defined using initial dim fn
        days_dry = 0 # Default 0
        days_exposed = 0 # Default 0 
        days_carrier = 0 # Default 0 
        trade_status = false #Eligibility for trading 
        lactation = round(age/365) - 1 #Lactation number
        pregstat = :P #Initial pregnancy status
        dic= Int(floor(rand(animalModel.rng, truncated(Rayleigh(82), 33, 117))))
        stress = false #If animal is in oestrus
        sex = :F #Sex of initial animals (always F)
        calving_season = :B3
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
            dims = dims
        )
        if isempty(pos, animalModel)
            add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
        end
    end

    # Add weaned ---------------------------------------------------------------------------
    for n in 1:floor(N*0.25*0.25)
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = (rand(animalModel.rng, 1:100, 2)..., 2)
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
        age = Int(floor(rand(animalModel.rng, truncated(Rayleigh(145), 97, 180)))) # Defined using initial age function
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
        calving_season = :B3
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
            dims = dims
        )
        if isempty(pos, animalModel)
            add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
        end
    end

# Calving period four  --------------------------------------------------------
    #Define the initial state of the system. Attributes for each animal in the system.
    for n in 1:floor(N*0.25)
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = (rand(animalModel.rng, 1:100, 2)..., 5)
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
        age = Int(floor(rand(truncated(Rayleigh(4*365),(2*365), (8*365))))) # Defined using initial age function
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
        stage = :L #Initial stage
        dim = Int(floor(rand(animalModel.rng, truncated(Rayleigh(55), 7, 90)))) # Defined using initial dim fn
        days_dry = 0 # Default 0
        days_exposed = 0 # Default 0 
        days_carrier = 0 # Default 0 
        trade_status = false #Eligibility for trading 
        lactation = round(age/365) - 1 #Lactation number
        pregstat =  :E # 85% in calf
        dic = 0 #Will get joined later
        stress = false #If animal is in oestrus
        sex = :F #Sex of initial animals (always F)
        calving_season = :B4
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
            dims = dims
        )
        if isempty(pos, animalModel)
            add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
        end
    end

    # Add the heifers ---------------------------------------------------

    for n in 1:floor(N*0.25*0.25)
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = (rand(animalModel.rng, 1:100, 2)..., 4)
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
        age = Int(floor(rand(truncated(Rayleigh(420),372, 455)))) # Defined using initial age function
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
        stage = :DH #Initial stage
        dim = 0 # Defined using initial dim fn
        days_dry = 0 # Default 0
        days_exposed = 0 # Default 0 
        days_carrier = 0 # Default 0 
        trade_status = false #Eligibility for trading 
        lactation = round(age/365) - 1 #Lactation number
        pregstat = :E #Initial pregnancy status
        dic= 0 # Will be mated soon
        stress = false #If animal is in oestrus
        sex = :F #Sex of initial animals (always F)
        calving_season = :B4
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
            dims = dims
        )
        if isempty(pos, animalModel)
            add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
        end
    end

    # Add calves ---------------------------------------------------------------------------
    for n in 1:floor(N*0.25*0.5)
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = (rand(animalModel.rng, 1:100, 2)..., 1)
        status = initial_status(n, init_ir, init_is) # Defined using initial status function
        age = Int(floor(rand(animalModel.rng, truncated(Rayleigh(55), 7, 90)))) # Defined using initial age function
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
        stage = :C #Initial stage
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
        calving_season = :B4
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
            dims = dims
        )
        if isempty(pos, animalModel)
            add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
        end
    end


       return animalModel

    end

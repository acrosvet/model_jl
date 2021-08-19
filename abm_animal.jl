# ABM - Animal  --------------------

  
    #Define model initialisation functions. 

    function initialiseModel(
        N = 100, #Default number of animals
        seed = 42, #Random seed
        animalProximityRadius = 0.5, #Radius for effective contact
        mortalityRateSens = 0.01/time_resolution, #Mort. (sensitive)
        mortalityRateRes = 0.015/time_resolution, #Mort. (resistant)
        movement = 0.1, #Movement in continuous space
        βᵣ = 0.3/time_resolution, #Beta (resistant) NOT TIME DEPENDENT?!
        βₛ = 0.6/time_resolution, #Beta (sensitive)
        init_is = 5, # Number initially infected sensitive
        init_ir = 1, # Number initially infected resistant
        inf_days_is = 0,
        inf_days_ir = 0,
        sponrec_is = 0.05/time_resolution, #chance of spontaneous recovery IS
        sponrec_ir = 0.04/time_resolution,  #chance of spontaneous recovery IR
        timestep = 1.0, #Set model timestep
        treatment = :U,
        days_treated = 0,
        treatment_prob = 0.3/time_resolution,
        treatment_duration = 5*time_resolution,
        since_tx = 0,
        res_carrier = 0.05/time_resolution,
        sens_carrier = 0.01/time_resolution, 
        bactopop = 0.0,
        submodel = initialisePopulation(),
        stage = :C,
        calday = 183,
        num_calves = (calday > 182 && calday < 272) ? N*0.2 : 0,
        num_weaned = (calday ≥ 272 && calday ≤ 365 ) ? N*0.2 : 0,
        num_heifers = N*0.3,
        num_lac = N - num_calves - num_weaned - num_heifers,
        dim = 0,
        lac = 0,
        days_dry = 0,
    )
    #End header
    #Body

    #Define the agent space. At present, avoid observing pen boundaries.
    agentSpace = ContinuousSpace((10,10), 1; periodic = true) #Relatinship to real space?
    #Specify the disease dynamics  as a Dictionary to be passed to the model
    pathogenProperties = @dict(
        animalProximityRadius,
        mortalityRateSens,
        mortalityRateRes,
        sponrec_ir,
        sponrec_is,
        timestep, 
        treatment_prob,
        treatment_duration, 
        since_tx,
        res_carrier,
        sens_carrier,
        bactopop,
        submodel,
        calday,
        stage,
        βᵣ,
        βₛ,
        movement, )# Dictionary of disease properties

    # Define the model: Agent type, agent space, properties, and type of random seed
    animalModel = ABM(AnimalAgent, agentSpace, properties = pathogenProperties, rng = MersenneTwister(seed))
    
    # Set the initial age of the animals
    function initial_age(n)
        if n <= num_calves
            rand(1:60)
        elseif n > (num_calves + 1) && n <= (num_calves + num_weaned)
            rand(61:(30*13))
        elseif n > (num_calves + num_weaned + 1 ) && n <= (num_calves + num_weaned + num_heifers)
            rand((13*30):(24*30))
        else n > (num_calves + num_weaned + num_heifers + 1) && n <= (num_calves + num_weaned + num_heifers + num_lac)
            rand((24*30):(6*365))
        end
    end

    # Set the initial dim

    function initial_dim(stage, calday)
    
        if stage == :L && calday ≥ 182 
                0
            else 
                365 - 182 
        end

    end

    # Set the initial lifestage 

    function initial_stage(age)
        if age < 60
            :C
        elseif age ≥ 60 && age ≤ 13*30
            :W
        elseif age > 13*30 && age ≤ 24*30
            :H
        elseif age > 24*30 
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


    #Define the initial state of the system. Attributes for each animal in the system.
    for n in 1:N
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = Tuple(10*rand(animalModel.rng, 2))
        status = initial_status(n, init_ir, init_is)
        age = initial_age(n)
        βᵣ = βᵣ
        βₛ = βₛ
        treatment = treatment
        treatment_prob = treatment_prob
        days_treated = days_treated
        treatment_duration = treatment_duration
        bactopop = 0.0
        submodel = submodel
        vel = initial_velocity(status, movement)
        stage = initial_stage(age)
        dim = initial_dim(stage,calday)
        days_dry = 0
        add_agent!(pos, animalModel, vel, age, status, βᵣ, βₛ, inf_days_is, inf_days_ir, treatment, days_treated, since_tx, bactopop, submodel, stage, dim, days_dry)
    end

        return animalModel
    end


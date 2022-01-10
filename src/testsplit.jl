function initialiseSplit(;
    farmno::Int8 = FarmAgent.id,
    farm_status::Int8,
    system::Int8,
    msd::Date,
    seed::Int8,
    optimal_stock::Int16,
    optimal_lactating::Int16,
    treatment_prob::Float32,
    treatment_length::Int8,
    carrier_prob::Float32,
    timestep::Int16,
    density_lactating::Int8,
    density_dry::Int8,
    density_calves::Int8,
    date::Date,
    vacc_rate::Float32,
    fpt_rate::Float32,
    prev_r::Float32,
    prev_p::Float32,
    prev_cr::Float32,
    prev_cp::Float32,
    vacc_efficacy::Float32
    )
    
    #Agent space =======================================================
    animals = Array{AnimalAgent}[]
  
    #Create the initial model parameters ===============================
    msd_2 = msd - Month(4)
    msd_3 = msd_4 = Date(0)
    current_stock = current_lactating = current_dry = current_heifers = current_dh = current_weaned = current_calves = 0
    optimal_dry = optimal_heifers = optimal_dh = optimal_weaned = optimal_calves = 0
    tradeable_stock = 0
    sending = receiving = Array{AnimalAgent}(undef, 15)
    rng = MersenneTwister(seed)
    pop_p = pop_r = pop_s = pop_d = 0
    id_counter = 0
    positions = Array{Array{Int}}[]
    processed = false
  
    N = optimal_stock
    optimal_spring = optimal_autumn = Int16(floor(N*0.5))
    current_spring = current_autumn = Int16(0) 
  
    #Set up the model ====================================================
  
    animalModel = AnimalModel(farmno, animals, timestep, date, rng, system, msd, msd_2, msd_3, msd_4, seed, farm_status, optimal_stock, treatment_prob, treatment_length, carrier_prob, current_stock, current_lactating, optimal_lactating, current_heifers, optimal_heifers, current_calves, optimal_calves, current_weaned, optimal_weaned, current_dh, optimal_dh, current_dry, optimal_dry, tradeable_stock, sending, receiving, density_lactating, density_calves, density_dry, positions, pop_r, pop_s, pop_p, pop_d, id_counter, vacc_rate, fpt_rate, prev_r, prev_p, prev_cr, prev_cp, vacc_efficacy, current_autumn, optimal_autumn, current_spring, optimal_spring)
    
    # Set the initial stock parameters
    animalModel.optimal_heifers = animalModel.optimal_weaned = animalModel.optimal_calves = animalModel.optimal_dh = animalModel.optimal_heifers = floor(0.3*animalModel.optimal_lactating)
    
  
    function initial_animals!(animalModel;stockno, stage, dic, dim, age, pregstat, calving_season)
        for cow in 1:stockno
            animalModel.id_counter += 1
            id = Int16(animalModel.id_counter)
            pos = [rand(animalModel.rng, 1:Int(floor(animalModel.density_dry*√animalModel.optimal_lactating)), 2)..., stage]
             while pos in animalModel.positions == true
                pos = [rand(animalModel.rng, 1:Int(floor(animalModel.density_dry*√animalModel.optimal_lactating)), 2)..., stage]
            end 
            push!(animalModel.positions, pos)
            status = Int8(initial_status!(animalModel))
            days_infected = status == 1 || status == 2 ? 1 : 0
            days_exposed = Int8(0)
            days_carrier = status == 5 || status == 6 ? 1 : 0
            days_recovered = Int8(0)
            days_treated = Int8(0)
            treatment = false
            pop_d = Float32(0.0)
            bacteriaSubmodel = initialiseBacteria(animalno = Int16(id), nbact = Int16(33*33), total_status = Int8(status), days_treated = Int8(days_treated), days_exposed = Int8(days_exposed), days_recovered = Int8(days_recovered), stress = false, seed = Int8(seed))
            pop_p = Float32(bacteriaSubmodel.pop_p)
            pop_r = Float32(bacteriaSubmodel.pop_r)
            stress = false
            sex = 1#Female
            lactation= round(age/365) - 1
            trade_status = 0#false
            neighbours = get_neighbours_animal(pos)
            carryover = false
            fpt = false
            vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
            susceptibility = vaccinated == true ?  animalModel.vacc_efficacy : 0.5
            animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility)    
            push!(animalModel.animals, animal)
        end
    end    


    animalModel.id_counter = 0
    
    #Initial stock classes
    stocktype  = Vector[:s1_dry, :s1_heifer, :s1_weaned, :s2_lac, :s2_heifer, :s2_weaned]
    all_stockno = Vector[floor(N*0.5*0.7), floor(N*0.5*0.25), floor(N*0.5*0.25), floor(N*0.5), floor(N*0.5*0.25), floor(N*0.5*0.25)]
    stages = Vector[6, 4, 2, 5, 4, 2]
    all_dim = Vector[0, 0, 0, Int16(floor(rand(animalModel.rng, truncated(Rayleigh(100), 37, 121)))), 0]
    all_dic = Vector[Int16(floor(rand(animalModel.rng, truncated(Rayleigh(240), 199, 280)))), Int16(floor(rand(animalModel.rng, truncated(Rayleigh(240), 199, 280)))), 0, 0, Int16(floor(rand(truncated(Rayleigh(42),(1), (60))))), 0]
    all_age = Vector[Int16(floor(rand(truncated(Rayleigh(5*365),(2*365), (8*365))))), 0, Int16(floor(rand(truncated(Rayleigh(365),(295), (385))))), Int16(floor(rand(truncated(Rayleigh(5*365),(2*365), (8*365))))), Int16(floor(rand(truncated(Rayleigh(2*365 - 4*30),(22*30 - 4*30), (25*30 - 4*30))))), Int16(floor(rand(animalModel.rng, truncated(Rayleigh(100), 37, 121)))) ]
    all_pregstat = Vector[1,1, 0, 0, 1, 0]
    all_seasons = Vector[1, 1, 1, 2, 2, 2]

    for i in 1:length(stocktype)
        initial_animals!(
            animalModel,
            stockno = all_stockno[i],
            stage = stages[i], 
            dic = all_dic[i],
            dim = all_dim[i],
            age = all_age[i],
            pregstat = all_pregstat[i],
            calving_season = all_seasons[i]
        )
    end

    count_animals!(animalModel)
  
  
    return animalModel
  
  
  end
  
 tmpmodel =  initialiseSplit(
        farmno = Int8(1),
        farm_status = Int8(2),
        system = Int8(2),
        msd = Date(2021,9,24),
        seed = Int8(42),
        optimal_stock = Int16(273),
        optimal_lactating = Int16(273),
        treatment_prob = Float32(0),
        treatment_length = Int8(3),
        carrier_prob = Float32(0.05),
        timestep = Int16(0),
        density_lactating = Int8(6),
        density_dry = Int8(7),
        density_calves = Int8(3),
        date = Date(2021,7,2),
        vacc_rate = Float32(0.0),
        fpt_rate = Float32(0.0),
        prev_r = Float32(0.01),
        prev_p = Float32(0.01),
        prev_cr = Float32(0.04),
        prev_cp = Float32(0.04),
        vacc_efficacy = Float32(0.1)
  )
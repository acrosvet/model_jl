    include("animal_na.jl")
    using LightGraphs
    using DataFrames 

    svars = DataFrame(CSV.File("./sensitivity_spring.csv"))

    mutable struct Farm
        id::Int
        neighbours::Array{Int}
        trades_from::Array{AnimalAgent}
        trades_to::Array{AnimalAgent}
        ncows::Int
        system::Int
        herd::AnimalModel
        traded::Bool 
        status::Int
    end

    mutable struct FarmModel
        timestep::Int
        farms::Array{Farm}
        rng::MersenneTwister
        data::Array{AnimalData}
        space::DataFrame
        svars::DataFrame
    end

    function initialiseFarms(;
    svars::DataFrame
    )

    #Set up the network
 
    numfarms = length(svars$optimal_stock)

    space = DataFrame(collect(edges(static_scale_free(numfarms,numfarms,3))))

    #Set up the initial population
        
    num_spring = Int(floor(perc_spring*numfarms))
    num_split = Int(floor(perc_split*numfarms))

    num_batch = Int(floor(perc_batch*numfarms))
    num_batch = 1
    id_counter = Int(0)

    farms = Array{Farm}(undef, numfarms)
    data = Array{AnimalData}(undef, numfarms)

    farmModel = FarmModel(0, farms, MersenneTwister(42), data, space, svars)

    farms = Array{Farm}(undef, (num_spring + num_split + num_batch))

    for spring in 1:num_spring
        id_counter += 1
        id = id_counter
        neighbours = space[space.src .== id, :].dst
        trades_from = []
        trades_to = []
        ncows = Int(floor(rand(farmModel.rng, truncated(Rayleigh(mean_hs), min_hs, max_hs))))
        system = 1
        status = 1
    # herd = 
        traded = false
        #data = herd.sim
        #variables = DataFrame
        farmModel.farms[id] = Farm(Int(id), neighbours, trades_from, trades_to, ncows, system, initialiseSpring(farmno = id, farm_status = status, system = system, msd = Date(2021,9,24), seed = 42, optimal_stock = ncows, optimal_lactating = ncows, treatment_prob = 0.0, treatment_length = 4, carrier_prob = 0.1, timestep = 0, density_lactating = 50, density_dry = 250, density_calves = 3, date = Date(2021,7,2), vacc_rate = 0.0, fpt_rate = 0.0, prev_r = 0.0, prev_p = 0.02, prev_cr = 0.0, prev_cp = 0.1, vacc_efficacy = 0.1, pen_decon = false), traded,  status)
    end

    for batch in 1:num_batch
        id_counter += 1
        id = id_counter
        @info id
        neighbours = space[space.src .== id, :].dst
        trades_from = []
        trades_to = []
        ncows = Int(floor(rand(farmModel.rng, truncated(Rayleigh(mean_hs), min_hs, max_hs))))
        system = 3
        status = 1
        #herd = 
        traded = false
        #data = herd.sim
        #variables = DataFrame
        farmModel.farms[id] = Farm(Int(id), neighbours, trades_from, trades_to, ncows, system, initialiseSplit(farmno = id, farm_status = status, system = system, msd = Date(2021,9,24), seed = 42, optimal_stock = ncows, optimal_lactating = ncows, treatment_prob = 0.0, treatment_length = 4, carrier_prob = 0.1, timestep = 0, density_lactating = 50, density_dry = 250, density_calves = 3, date = Date(2021,7,2), vacc_rate = 0.0, fpt_rate = 0.0, prev_r = 0.0, prev_p = 0.02, prev_cr = 0.0, prev_cp = 0.1, vacc_efficacy = 0.1, pen_decon = false), traded, status)
    end

    for split in 1:num_split
        id_counter += 1
        id = id_counter
        @info id_counter
        neighbours = space[space.src .== id, :].dst
        trades_from = []
        trades_to = []
        ncows = Int(floor(rand(farmModel.rng, truncated(Rayleigh(mean_hs), min_hs, max_hs))))
        system = 1
        status = 1
        #herd = 
        traded = false
        #data = herd.sim
        #variables = DataFrame
        farmModel.farms[id] = Farm(Int(id), neighbours, trades_from, trades_to, ncows, system, initialiseBatch(farmno = id, farm_status = status, system = system, msd = Date(2021,9,24), seed = 42, optimal_stock = ncows, optimal_lactating = ncows, treatment_prob = 0.0, treatment_length = 4, carrier_prob = 0.1, timestep = 0, density_lactating = 50, density_dry = 250, density_calves = 3, date = Date(2021,7,2), vacc_rate = 0.0, fpt_rate = 0.0, prev_r = 0.0, prev_p = 0.02, prev_cr = 0.0, prev_cp = 0.1, vacc_efficacy = 0.1, pen_decon = false), traded, status)
    end



    num_r = Int(floor(prop_res*numfarms))

    resistant = sample(farmModel.farms, num_r)
    for resist in resistant
        type = farmModel.farms[resist].system
        if system == 1
            resist = farmModel.farms[resist]
        farmModel.farms[resist] = initialiseSpring(
            farmno = resist.id, 
            farm_status = 2, 
            system = resist.system, 
            msd = Date(2021,9,24), 
            seed = 42, 
            optimal_stock = resist.optimal_lactating, 
            optimal_lactating = resist.optimal_lactating, 
            treatment_prob = 0.0, 
            treatment_length = 4, 
            carrier_prob = 0.1, 
            timestep = 0, 
            density_lactating = 50, 
            density_dry = 250, 
            density_calves = 3, 
            date = Date(2021,7,2), 
            vacc_rate = 0.0, 
            fpt_rate = 0.0, 
            prev_r = 0.1, 
            prev_p = 0.01, 
            prev_cr = 0.05, 
            prev_cp = 0.05, 
            vacc_efficacy = 0.1, 
            pen_decon = false)
        elseif system == 2
            resist = farmModel.farms[resist]
            farmModel.farms[resist] = initialiseSplit(
            farmno = resist.id, 
            farm_status = 2, 
            system = resist.system, 
            msd = Date(2021,9,24), 
            seed = 42, 
            optimal_stock = resist.optimal_lactating, 
            optimal_lactating = resist.optimal_lactating, 
            treatment_prob = 0.0, 
            treatment_length = 4, 
            carrier_prob = 0.1, 
            timestep = 0, 
            density_lactating = 50, 
            density_dry = 250, 
            density_calves = 3, 
            date = Date(2021,7,2), 
            vacc_rate = 0.0, 
            fpt_rate = 0.0, 
            prev_r = 0.1, 
            prev_p = 0.01, 
            prev_cr = 0.05, 
            prev_cp = 0.05, 
            vacc_efficacy = 0.1, 
            pen_decon = false)
        elseif system == 3
            resist = farmModel.farms[resist]
            farmModel.farms[resist] = initialiseSpring(
            farmno = resist.id, 
            farm_status = 2, 
            system = resist.system, 
            msd = Date(2021,9,24), 
            seed = 42, 
            optimal_stock = resist.optimal_lactating, 
            optimal_lactating = resist.optimal_lactating, 
            treatment_prob = 0.0, 
            treatment_length = 4, 
            carrier_prob = 0.1, 
            timestep = 0, 
            density_lactating = 50, 
            density_dry = 250, 
            density_calves = 3, 
            date = Date(2021,7,2), 
            vacc_rate = 0.0, 
            fpt_rate = 0.0, 
            prev_r = 0.1, 
            prev_p = 0.01, 
            prev_cr = 0.05, 
            prev_cp = 0.05, 
            vacc_efficacy = 0.1, 
            pen_decon = false)
        end
    end

    for farm in farmModel.farms

    end


    return farmModel

    end

    farmModel = initialiseFarms(
        numfarms = 10, 
        prop_res = 0.05, 
        perc_spring = 0.3,
        perc_split = 0.65,
        perc_batch = 0.05,
        min_hs = 80,
        max_hs = 1500,
        mean_hs = 273
    )

    function day_trader!(farmModel)
        farmModel.timestep % 7 != 0 && return
        rand(farmModel.rng) > 0.1 && return
       
        #Broker trades

        for farm in farmModel.farms
            farm.traded == true && continue
            length(farm.neighbours) == 0 && continue
            trader = farmModel.farms[farm.neighbours[rand(1:length(farm.neighbours))]]
            trader.trades_from = trader.herd.sending
            trader.traded == true && continue
            farm.trades_to = trader.trades_from
            didtrades = 0
            for bought in 1:length(farm.trades_to)
                isassigned(farm.trades_to, bought) == false && continue
               # @info bought
                farm.herd.id_counter += 1
                farm.trades_to[bought].id = farm.herd.id_counter
                push!(farm.herd.animals, farm.trades_to[bought])
                didtrades += 1
            end
            didtrades == 0 && continue
            farm.traded = true
            trader.traded = true
            for sold in 1:length(trader.trades_from)
                isassigned(trader.trades_from, sold) == false && continue
                findfirst(isequal(trader.trades_from[sold]), trader.herd.animals) === nothing && continue
                deleteat!(trader.herd.animals, findfirst(isequal(trader.trades_from[sold]), trader.herd.animals))
            end
            @info "Trade!"
        end
    end

    function farm_step!(farmModel)
        for farm in farmModel.farms
            farm.traded = false
            farm.trades_from = []
            farm.trades_to = []
        end
        farmModel.timestep += 1

        day_trader!(farmModel)

        Threads.@threads for farm in farmModel.farms
            animal_step!(farm.herd)
        end

    end

    @time [farm_step!(farmModel) for i in 1:3651]



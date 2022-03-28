using StatsBase

    
include("animal_na.jl")
using LightGraphs
 using DataFrames 
    


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
        #data::Array{AnimalData}
        space::DataFrame
        svars::DataFrame
        movements::DataFrame
        statuses::DataFrame
        run::Int
    end

function initialiseFarms(;
    svars::DataFrame,
    run::Int
    )

    #Set up the network
 
    numfarms = length(svars.optimal_stock)

    space = DataFrame(collect(edges(static_scale_free(numfarms,numfarms,3))))
    
    movements = DataFrame(
        date = Date(0),
        from = 0,
        to = 0,
        from_status = 0,
        to_status = 0,
        infected_movements = false,
        typeofinf = 999
    )

    statuses = DataFrame(
        date = Date(0),
        farm = 0,
        status = 0,
        pop_p = 0.0,
        pop_r = 0.0,
        pop_cp = 0.0,
        pop_cr = 0.0,
        pop_s = 0.0
    )

    farms = Array{Farm}(undef,numfarms)
    farmModel = FarmModel(0,farms, MersenneTwister(42), space, svars, movements, statuses, run)

    #Set up the initial population
   Threads.@threads for i in 1:length(svars.farm)
        id = svars.farm[i]
        neighbours = space[space.src .== id, :].dst
        trades_from = []
        trades_to = []
        ncows = svars.optimal_stock[i]
        system = svars.calving_system[i]
        status = svars.status[i]
        if svars.calving_system[i] == 1
            herd = initialiseSpring(
                farmno = Int16(id),
                farm_status = Int16(status),
                system = Int16(system),
                msd = Date(2021,9,24),
                seed = Int16(42),
                optimal_stock = Int16(ncows),
                optimal_lactating = Int16(ncows),
                treatment_prob = Float16(svars.treatment_prob[i]),
                treatment_length = Int16(5),
                carrier_prob = Float16(0.1),
                timestep = Int16(0),
                density_lactating = Int16(svars.density_lactating[i]),
                density_dry = Int16(svars.density_dry[i]),
                density_calves = Int16(svars.density_calves[i]),
                date = Date(2021,7,2),
                vacc_rate = Float16(svars.vacc_rate[i]),
                fpt_rate = Float16(svars.fpt_rate[i]),
                prev_r = Float16(svars.prev_r[i]),
                prev_p = Float16(svars.prev_p[i]),
                prev_cr = Float16(svars.prev_cr[i]),
                prev_cp = Float16(svars.prev_cp[i]),
                vacc_efficacy = Float16(svars.vacc_efficacy[i]),
                pen_decon = svars.pen_decon[i]
            )
        elseif svars.calving_system[i] == 2
            herd = initialiseSplit(
                farmno = Int16(id),
                farm_status = Int16(status),
                system = Int16(system),
                msd = Date(2021,9,24),
                seed = Int16(42),
                optimal_stock = Int16(ncows),
                optimal_lactating = Int16(ncows),
                treatment_prob = Float16(svars.treatment_prob[i]),
                treatment_length = Int16(5),
                carrier_prob = Float16(0.1),
                timestep = Int16(0),
                density_lactating = Int16(svars.density_lactating[i]),
                density_dry = Int16(svars.density_dry[i]),
                density_calves = Int16(svars.density_calves[i]),
                date = Date(2021,7,2),
                vacc_rate = Float16(svars.vacc_rate[i]),
                fpt_rate = Float16(svars.fpt_rate[i]),
                prev_r = Float16(svars.prev_r[i]),
                prev_p = Float16(svars.prev_p[i]),
                prev_cr = Float16(svars.prev_cr[i]),
                prev_cp = Float16(svars.prev_cp[i]),
                vacc_efficacy = Float16(svars.vacc_efficacy[i]),
                pen_decon = svars.pen_decon[i]
            )
        else 
            herd = initialiseBatch(
                farmno = Int16(id),
                farm_status = Int16(status),
                system = Int16(system),
                msd = Date(2021,9,24),
                seed = Int16(42),
                optimal_stock = Int16(ncows),
                optimal_lactating = Int16(ncows),
                treatment_prob = Float16(svars.treatment_prob[i]),
                treatment_length = Int16(5),
                carrier_prob = Float16(0.1),
                timestep = Int16(0),
                density_lactating = Int16(svars.density_lactating[i]),
                density_dry = Int16(svars.density_dry[i]),
                density_calves = Int16(svars.density_calves[i]),
                date = Date(2021,7,2),
                vacc_rate = Float16(svars.vacc_rate[i]),
                fpt_rate = Float16(svars.fpt_rate[i]),
                prev_r = Float16(svars.prev_r[i]),
                prev_p = Float16(svars.prev_p[i]),
                prev_cr = Float16(svars.prev_cr[i]),
                prev_cp = Float16(svars.prev_cp[i]),
                vacc_efficacy = Float16(svars.vacc_efficacy[i]),
                pen_decon = svars.pen_decon[i]
            )
        end
        traded = false
        farmModel.farms[i] = Farm(id, neighbours, trades_from, trades_to, ncows, system, herd, traded, status)
    end

    return farmModel

    end


     function day_trader!(farmModel)
        farmModel.timestep % 7 != 0 && return
        rand(farmModel.rng) > 0.05 && return
       
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
                push!(farmModel.movements.from, trader.id)
                push!(farmModel.movements.to, farm.id)
                push!(farmModel.movements.from_status, trader.status)
                push!(farmModel.movements.to_status, farm.status)
                push!(farmModel.movements.infected_movements, ifelse(trader.trades_from[sold].status != 0, true, false))
                push!(farmModel.movements.typeofinf, trader.trades_from[sold].status)
                push!(farmModel.movements.date, farm.herd.date)
            end
            @info "Trade!"
        end
    end

    function export_statuses!(farmModel)
        for farm in farmModel.farms
            push!(farmModel.statuses.date, farm.herd.date)
            push!(farmModel.statuses.farm, farm.id)
            push!(farmModel.statuses.status, farm.status)
            push!(farmModel.statuses.pop_p, farm.herd.pop_p/length(farm.herd.animals))
            push!(farmModel.statuses.pop_r, farm.herd.pop_r/length(farm.herd.animals))
            push!(farmModel.statuses.pop_cp, farm.herd.sim.pop_car_p[farmModel.timestep]/length(farm.herd.animals))
            push!(farmModel.statuses.pop_cr, farm.herd.sim.pop_car_r[farmModel.timestep]/length(farm.herd.animals))
            push!(farmModel.statuses.pop_s, farm.herd.pop_s/length(farm.herd.animals))

        end
    end

     function farm_step!(farmModel)
        Threads.@threads for farm in farmModel.farms
            farm.traded = false
            farm.trades_from = []
            farm.trades_to = []
            if farm.herd.pop_r > 0
                farm.status = 2
            end
        end
        farmModel.timestep += 1

        day_trader!(farmModel)

        #animal_step!.(farmModel.farms.herd)

         Threads.@threads for farm in farmModel.farms
           animal_step!(farm.herd)
        end 

        export_statuses!(farmModel)

        seq = farmModel.run
        if farmModel.timestep % 100 == 0
            CSV.write("./export/cache_farm_run_statuses_$seq.csv", farmModel.statuses)
            CSV.write("./export/cache_farm_run_movements_$seq.csv", farmModel.movements)
        end
    end

function sensitivity(numruns, numdays)
     for i in 1:numruns
        time = i 
        #svars = DataFrame(CSV.File("./sense/sensitivity_args_$time.csv"))
        svars = DataFrame(CSV.File("./sense/sensitivity_args_1.csv"))
        @time farmModel = initialiseFarms(svars = svars, run = i);

        @time [farm_step!(farmModel) for i in 1:numdays]
       
        seq = svars.run[i]
        @info "Run $seq complete."

        CSV.write("./export/farm_run_statuses_$seq.csv", farmModel.statuses)
        CSV.write("./export/farm_run_movements_$seq.csv", farmModel.movements)
        CSV.write("./export/farm_run_space_$seq.csv",farmModel.space)
    end
end


@benchmark sensitivity(1,3651)    



    




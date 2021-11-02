
function initialiseFarms(
    seed = 42,
    date = Date(2021,7,2),
    tradelevel = 2,
    timestep = 1,
    step = 0;
    numfarms::Int = 5,
    nbact::Int = 10000,
    dims::Int = 100,
    num_res::Int = 1
   )


FarmProperties = @dict(
    numfarms,
    seed,
    rng = MersenneTwister(seed),
    contacts = 0,
    tradelevel,
    timestep,
    date,
    step,
    dims,
)

            
agentSpace = GraphSpace(static_scale_free(numfarms, numfarms, 3))

farmModel = ABM(FarmAgent, agentSpace, properties = FarmProperties)

id = 0

function farm_status(id, ncows, nbact, dims, status)
    if id % 5 == 0
        initialiseSeasonal(ncows, farm_id = id, seed = id, nbact = nbact, dims = dims, farm_status = status)
    elseif id % 4 == 0
        initialiseBatch(ncows, farm_id = id, seed = id, nbact = nbact, dims = dims, farm_status = status)
    else
        initialiseSplit(ncows, farm_id = id, seed = id, nbact = nbact, dims = dims, farm_status = status)
    end
end

function farm_system(id)
    if id % 5 == 0
        :Seasonal
    elseif id % 4 == 0
        :Batch
    else
        :Split
    end
end

function set_status(id, num_res)
    if id <= num_res
        :R
    elseif id % 5 == 0
        :IS
    else
        :S
    end
end

for farm in 1:numfarms
    id +=1
    status = set_status(id, num_res)
    tradelevel = rand(1:5)
    ncows = rand(150:220)
    system = farm_system(id)
    trades_from = []
    trades_to = []
    traded = false
    animalModel = farm_status(id, ncows, nbact, dims, status)
    add_agent!(id, farmModel, status, tradelevel, trades_from, trades_to, ncows, system, animalModel, traded)
    
end
    

    return farmModel
end

#farmModel = initialiseFarms()

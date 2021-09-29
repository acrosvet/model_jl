
function initialiseFarms(
    seed = 42,
    date = Date(2021,7,2),
    tradelevel = 2,
    timestep = 1,
    step = 0;
    numfarms::Int = 5,
    nbact::Int = 10000,
    dim::Int = 100
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
    dim,
)

            
agentSpace = GraphSpace(static_scale_free(numfarms, numfarms, numfarms/5))

farmModel = ABM(FarmAgent, agentSpace, properties = FarmProperties)

id = 0

function farm_status(id, ncows, nbact, dim)
    if id % 5 == 0
        initialiseSeasonal(ncows, farm_id = id, seed = id, nbact = nbact, dim = dim)
    elseif id % 4 == 0
        initialiseBatch(ncows, farm_id = id, seed = id, nbact = nbact, dim = dim)
    else
        initialiseSplit(ncows, farm_id = id, seed = id, nbact = nbact, dim = dim)
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

for farm in 1:numfarms
    id +=1
    status = farm % 2 == 0 ? :S : :I
    tradelevel = rand(1:5)
    ncows = rand(150:220)
    system = farm_system(id)
    trades_from = []
    trades_to = []
    traded = false
    animalModel = farm_status(id, ncows, nbact, dim)
    add_agent!(id, farmModel, status, tradelevel, trades_from, trades_to, ncows, system, animalModel, traded)
    
end
    

    return farmModel
end

#farmModel = initialiseFarms()

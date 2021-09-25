
function initialiseFarms(
    numfarms = 5,
    seed = 42,
    date = Date(2021,7,2),
    tradelevel = 2,
    timestep = 1,
   
)


FarmProperties = @dict(
    numfarms,
    seed,
    rng = MersenneTwister(seed),
    contacts = 0,
    tradelevel,
    timestep,
    date,
)


agentSpace = GraphSpace(complete_digraph(numfarms))

farmModel = ABM(FarmAgent, agentSpace, properties = FarmProperties)

id = 0

for farm in 1:numfarms
    id +=1
    status = farm % 2 == 0 ? :S : :I
    tradelevel = rand(1:5)
    ncows = rand(150:220)
    system = :Spring
    trades_from = []
    trades_to = []
    animalModel = initialiseSeasonal(ncows, farm_id = id)
    add_agent!(id, farmModel, status, tradelevel, trades_from, trades_to, ncows, system, animalModel)
    
end

    return farmModel
end

#farmModel = initialiseFarms()

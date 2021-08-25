
function initialiseFarms(
    numfarms = 2,
    seed = 42,
    calday = rand(1:365),
    tradelevel = 2,
    timestep = 1
)


FarmProperties = @dict(
    numfarms,
    seed,
    rng = MersenneTwister(seed),
    contacts = 0,
    calday,
    tradelevel,
    timestep,
)


agentSpace = GraphSpace(complete_digraph(numfarms))

farmModel = ABM(FarmAgent, agentSpace, properties = FarmProperties)

id = 0

for farm in 1:numfarms
    id +=1
    status = farm % 2 == 0 ? :S : :I
    tradelevel = rand(1:5)
    ncows = rand(100:150)
    system = :Spring
    trades_from = 0
    trades_to = 0
    animalModel = initialiseModel(ncows)
    #submodel = submodel
    add_agent!(id, farmModel, status, tradelevel, trades_from, trades_to, ncows, system, animalModel)
    
end

    return farmModel
end

farmModel = initialiseFarms()

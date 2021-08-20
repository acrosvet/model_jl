using Agents
using SimpleWeightedGraphs: SimpleWeightedDiGraph # will make social network
using SparseArrays: findnz                        # for social network connections
using Random: MersenneTwister  
using LightGraphs
using DrWatson

mutable struct FarmAgent <: AbstractAgent
    id::Int
    pos::Tuple{Float64,Float64}
    status::Symbol #Infection status
    calday::Int # Calendar day
    tradelevel::Int #Trading relationships
    #contacts::Vector #Contacts
    ncows::Int #Number of animals
    system::Symbol #Calving system
end

function initialiseFarms(
    numfarms = 20,
    seed = 42,
    spacing = 2
)

FarmProperties = @dict(
    numfarms,
    seed,
    rng = MersenneTwister(seed),
    contacts = SimpleWeightedDiGraph(numfarms)
)

agentSpace = ContinuousSpace((100,100), spacing; periodic = false)

farmModel = ABM(FarmAgent, agentSpace, properties = FarmProperties)

for farm in 1:numfarms
    pos = Tuple(rand(farmModel.rng, 2))
    status = :S
    calday = 183
    tradelevel = 3
    ncows = rand(350:1000)
    system = :Spring 
    add_agent!(pos,farmModel, status, calday, tradelevel, ncows, system)
    traded = rand(farmModel.rng, filter(s -> s != farm, 1:numfarms))
    add_edge!(farmModel.contacts, farm, traded)
    not_traded = rand(farmModel.rng, filter(s -> s != farm, 1:numfarms))
    add_edge!(farmModel.contacts, farm, not_traded)

end
    return farmModel
end

function agent_step!(FarmAgent, farmModel)

    network = farmModel.contacts.weights[FarmAgent.id, :]

    contacted, weight = findnz(network)
    
end

# Def - BacterialAgent --------------------------------

mutable struct BacterialAgent <: AbstractAgent
    id::Int64
    pos::NTuple{2, Int}
    status::Symbol
    strain::Int64
    strain_status::Symbol
    fitness::Float64
end


# Def - AnimalAgent --------------------
mutable struct AnimalAgent <: AbstractAgent
    id::Int
    pos::NTuple{2,Float64}
    vel::NTuple{2, Float64}
    age::Int
    status::Symbol
    βₛ::Float64
    βᵣ::Float64
    inf_days::Int
    days_exposed::Int
    days_carrier::Int
    treatment::Symbol
    days_treated::Int
    since_tx::Int
    bactopop::Float64
    submodel::AgentBasedModel
    stage::Symbol
    dim::Int
    days_dry::Int
    trade_status::Bool
    agenttype::Symbol
    lactation::Int
    pregstat::Symbol
end

mutable struct FarmAgent <: AbstractAgent
    id::Int
    pos::Int
    status::Symbol #Infection status
    tradelevel::Int #Trading relationships
    trades_from::Vector
    trades_to::Vector
    ncows::Int #Number of animals
    system::Symbol #Calving system
    animalModel::AgentBasedModel
   # daytraders::Dict
end
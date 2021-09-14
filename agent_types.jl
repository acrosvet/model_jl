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
    id::Int # Animal ID
    pos::Dims{3} # Position, interaction dynamics
    age::Int # Animal age
    status::Symbol # Infection status
    βₛ::Float64 # Transmission coefficient (sensitive)
    βᵣ::Float64 # Transmission coefficient (resistant)
    inf_days::Int # Days infected with any strain
    days_exposed::Int # Days exposed
    days_carrier::Int # Days of carrier status
    treatment::Symbol # Treated or not
    days_treated::Int # Days treated
    since_tx::Int # Days since treatment
    bactopop::Float64 # Bacterial population
    submodel::AgentBasedModel #Bacterial model
    stage::Symbol # Life stage
    dim::Int # Days in milk
    days_dry::Int #Number of days dry
    trade_status::Bool #Trading eligibility
    agenttype::Symbol
    lactation::Int # Lactation number
    pregstat::Symbol # Pregnancy status
    dic::Int # Days in calf
    heat::Bool
    sex::Symbol
    calving_season::Symbol
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
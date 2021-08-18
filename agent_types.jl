# Def - BacterialAgent --------------------------------

mutable struct BacterialAgent <: AbstractAgent
    id::Int64
    pos::NTuple{2, Int}
    status::Symbol
    strain::Int64
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
    inf_days_is::Int
    inf_days_ir::Int
    treatment::Symbol
    days_treated::Int
    since_tx::Int
    bactopop::Float64
    submodel::AgentBasedModel
    stage::Symbol
end

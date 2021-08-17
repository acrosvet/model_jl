"""Define a CalfAgent with the following attributes:
* status - infection status Symbol:: S, I, R 
* age - age in days
"""
mutable struct CalfAgent <: AbstractAgent
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
end

#Define the time resolution initially in hours

const time_resolution = 24

mutable struct BacterialAgent <: AbstractAgent
    id::Int64
    pos::NTuple{2, Int}
    bactostatus::Symbol
    strain::Int64
    days_treated::Int
    age::Int
end

const time_units = 24


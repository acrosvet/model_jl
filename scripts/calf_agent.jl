# Define the calves and their attributes


mutable struct Calves <: AbstractAgent
    id::Int
    pos::NTuple{2,Float64}
    vel::NTuple{2,Float64}
    mass::Float64
    days_infected::Int  # number of days since is infected
    status::Symbol  # :S, :I or :R
    β_s::Float64
    age::Int64 # Integer for age in days, will change every day
    #fpt::Bool # Boolean value for passive transfer

end
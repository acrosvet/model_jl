mutable struct FarmAgent <: AbstractAgent
    id::Int
    pos::Tuple{Float64,Float64}
    status::Symbol
    calday::Int
    year::Int
    tradelevel::Int
    reprate::Float64
    contacts::Vector
end

using Agents
using DrWatson

## Define the agents
mutable struct BacterialAgent <: AbstractAgent
    id::Int64
    pos::NTuple{2, Float64}
    vel::NTuple{2, Float64}
    bactostatus::Symbol
    treatment::Symbol
    days_treated::Int64
    nstrains::Int64
end

## Define the model

function initialisePopulation(

    nbact = 1.7e5,
    seed = 42,
    contactRadius = 0,
    senesence = 0.05/time_units,
    proliferation = 0.05/time_units,
    bactostatus = :S,
    days_treated = 0,
    treatment = :N,
    nstrains = 0
)

agentSpace = ContinuousSpace((1,1), 1; periodic = true)

properties = @dict(
    nbact = nbact,
    seed = seed,
    contactRadius = contactRadius,
    senesence = senesence,
    proliferation = proliferation,
    bactostatus = bactostatus,
    days_treated = days_treated,
    treatment = treatment,
    nstrains = nstrains,
)

bacteriaModel = ABM(BacterialAgent, agentSpace, properties = properties, rng = MersenneTwister(seed))

function initial_population(n, nbact)
    init_r = rand(1:nbact, 1)
    init_s = nbact - init_r

    if n ≤ init_r
        :R 
    elseif n ≥ init_r + 1
        :S

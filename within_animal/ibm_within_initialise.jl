using Agents
using DrWatson
using Random

## Define the agents
mutable struct BacterialAgent <: AbstractAgent
    id::Int64
    pos::NTuple{2, Float64}
    vel::NTuple{2, Float64}
    bactostatus::Symbol
    treatment::Symbol
    strain::Int64
end

## Define the model

const time_units = 24

function initialisePopulation(

    nbact = 1000,
    seed = 42,
    contactRadius = 0,
    senesence = 0.05/time_units,
    proliferation = 0.05/time_units,
    movement = 0.05,
    bactostatus = :S,
    treatment = :N,
    strain = 1,
    nstrains = 4,
)

agentSpace = ContinuousSpace((1,1), 1; periodic = true)

properties = @dict(
    nbact = nbact,
    seed = seed,
    contactRadius = contactRadius,
    senesence = senesence,
    proliferation = proliferation,
    bactostatus = bactostatus,
    treatment = treatment,
    nstrains = nstrains,
    strain = strain,
    movement = movement,
)

bacterialModel = ABM(BacterialAgent, agentSpace, properties = properties, rng = MersenneTwister(seed))

# Set the starting strain of each bateria
function initial_strain(nstrains)

        return(rand(1:nstrains))
end


# Populate resistance according to strains type 

function initial_resistance(nstrains, strain)
    for i in 1:nstrains
        if strain == i && rand() < 0.25
            return(:R)
        else
            return(:S)
        end
    end
end

# Define the initial initial velocity

function initial_velocity(bactostatus, movement)
    if bactostatus == :S
        sincos(2π*rand(bacterialModel.rng)) .*movement
    else
        sincos(2π*rand(bacterialModel.rng)) .*(movement)
    end
end
            

# Set up the initial parameters
for n in 1:nbact
    treatment = treatment
    strain = initial_strain(nstrains)
    bactostatus = initial_resistance(nstrains, strain)
    pos = Tuple(rand(bacterialModel.rng, 2))
    vel = initial_velocity(bactostatus, movement)
    add_agent!(pos, bacterialModel, vel, bactostatus, treatment, strain)
end

    return bacterialModel

end

bacterialModel = initialisePopulation()


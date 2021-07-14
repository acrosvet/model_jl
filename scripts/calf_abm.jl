using Base: Int64, Float64
# Define the modules that are gooing to be used

using DrWatson: @dict
using Agents, Random, DataFrames, LightGraphs
using Distributions: Poisson, DiscreteNonParametric
using CairoMakie
using InteractiveDynamics

cd(@__DIR__) #src

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


# Define the model --------------------------------------

const steps_per_day = 24 # Number of time steps per day


function init_calf_sir(;
    infection_period = 3 * steps_per_day, #Infectious for 3 days
    detection_time = 0.5 * steps_per_day, # Detected after 0.5 days 
    #treatment_probability = 0.8, # 80% chance of being treated
    isolated = 3.0, # in percentage # 3% isolated 
    interaction_radius = 0.05, # UNITS UNCLEAR
    dt = 1.0, #Timestep
    speed = 0.002, #Speed of movement, relative to what?
    death_rate = 0.05, # 5% mortality
    N = 30, #30 calves in a pen
    initial_infected_sens = 3.0, # Initial sensitive
    initial_infected_res = 1.0, # Initial infected resistant
    seed = 42, # Random seed
    βmin_s = 0.2, # Minimum transmission
    βmax_s = 0.4, # Maximum transmission
)

    properties = @dict(
        infection_period,
        initial_infected_sens,
        initial_infected_res,
    #    treatment_probability,
        detection_time,
        death_rate,
        interaction_radius,
        dt,
    )



    space = ContinuousSpace((1,1), 0.02)# How to grid size and spacing affect this?

    model = ABM(Calves, space, properties = properties, rng = MersenneTwister(seed))

    ## Add initial individuals
    for ind in 1:N
        pos = Tuple(rand(model.rng, 2))
        status = ind ≤ N - initial_infected_sens - initial_infected_res ? :S : :IS 
        isisolated = ind ≤ isolated * N
        mass = isisolated ? Inf : 1.0 # Make sure the isolated calves don't move
        vel = isisolated ? (0.0, 0.0) : sincos(2π * rand(model.rng)) .* speed # Define a function for how they move
        age = 1
        ## very high transmission probability
        ## we are modelling close encounters after all
        β_s = (βmax_s - βmin_s) * rand(model.rng) + βmin_s
        add_agent!(pos, model, vel, mass, 0, status, β_s)
    end

    return model
end
nothing # hide

sir_model = init_calf_sir()


sir_colors(a) = a.status == :S ? "#2b2b33" : a.status == :IS ? "#bf2642" : "#338c54"

fig, abmstepper = abm_plot(sir_model; ac = sir_colors)
fig # display figure